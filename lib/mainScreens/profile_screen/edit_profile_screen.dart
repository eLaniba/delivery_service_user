import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/users.dart';
import 'package:delivery_service_user/services/phone_auth_service.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:delivery_service_user/widgets/circle_image_avatar.dart';
import 'package:delivery_service_user/widgets/circle_image_upload_option.dart';
import 'package:delivery_service_user/widgets/confirmation_dialog.dart';
import 'package:delivery_service_user/widgets/crop_image_screen.dart';
import 'package:delivery_service_user/widgets/custom_text_field.dart';
import 'package:delivery_service_user/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_user/widgets/show_floating_toast.dart';
import 'package:delivery_service_user/widgets/status_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  XFile? _imgProfile;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _verificationId = '';

  // Get the current user ID from Firebase Auth
  String? get currentUserId => firebaseAuth.currentUser!.uid;

  // Stream for the current user document from Firestore
  Stream<DocumentSnapshot<Map<String, dynamic>>> get _userStream {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .snapshots();
  }

  // Save profile changes to Firestore
  Future<void> _saveProfile() async {
    if (currentUserId == null) return;
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'userName': _nameController.text.trim(),
      // 'userEmail': _emailController.text,
      'userPhone': formatPhoneNumber(_phoneController.text.trim()),
    });

    //Local storage update
    sharedPreferences!.setString('name', _nameController.text.trim());
    sharedPreferences!.setString('phone', _phoneController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green,),
    );

    Navigator.pop(context);
  }

  Future<void>_getImage(ImageSource source) async {
    // 1. Pick the image from the camera or gallery.
    final XFile? imageXFile = await ImagePicker().pickImage(source: source);
    if (imageXFile == null) return;

    // Convert the picked file to bytes.
    final imageData = await imageXFile.readAsBytes();

    //2. Determine the aspect ratio
    double aspectRatio = 1.0;

    // 3. Navigate to the crop screen.
    final dynamic cropResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CropImageScreen(imageData: imageData, aspectRatio: aspectRatio),
      ),
    );

    Uint8List? croppedImageData;

    if (cropResult is Uint8List) {
      croppedImageData = cropResult;
    } else if (cropResult is CropSuccess) {
      croppedImageData = cropResult.croppedImage;
    }

    if (croppedImageData != null) {
      // Optionally convert to XFile if needed before updating state.
      _imgProfile = await convertUint8ListToXFile(croppedImageData);
      bool? isConfirm = await ConfirmationDialog.show(context, 'Are you sure you want to change your profile?');

      showFloatingToast(context: context, message: 'Uploading image...', duration: const Duration(seconds: 25));

      if (isConfirm == true) {
        String uid = sharedPreferences!.getString('uid')!;
        String profileFileName = 'profile_file';
        String profileFilePath = 'users/$uid/images/$profileFileName';
        String profileURL = await uploadFileAndGetDownloadURL(file: _imgProfile!, storagePath: profileFilePath);

        await firebaseFirestore.collection("users").doc(uid).update({
          'userProfileURL': profileURL,
        });

        await sharedPreferences!.setString('profileURL', profileURL);

        showFloatingToast(context: context, message: 'Profile image has been updated successfully', backgroundColor: Colors.green);
      }

    }
  }

  Future<void> verifyAndActivatePhone(String phoneNumber, BuildContext context) async {
    showFloatingToast(context: context, message: 'Verifying phone number...', duration: const Duration(seconds: 30));
    final User? user = firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('No user signed in');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user signed in")),
      );
      return;
    }

    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _linkPhoneNumber(user, credential, context);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("Verification failed: ${e.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Verification failed: ${e.message}"),
              backgroundColor: Colors.red,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Store verificationId for later use
          _verificationId = verificationId;

          // Show dialog to enter OTP
          String? smsCode = await _showOtpDialog(context);

          if (smsCode != null && smsCode.isNotEmpty) {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );
            await _linkPhoneNumber(user, credential, context);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint("Code auto-retrieval timeout");
          _verificationId = verificationId; // Might be useful for retry
        },
      );
    } catch (e) {
      debugPrint("Error in verifyPhoneNumber: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Helper method to link phone number and update Firestore
  Future<void> _linkPhoneNumber(User user, PhoneAuthCredential credential, BuildContext context) async {
    try {
      UserCredential userCredential = await user.linkWithCredential(credential);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'phoneVerified': true,
        'userPhone': userCredential.user?.phoneNumber,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone verified successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Error linking phone: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.message ?? 'Failed to link phone number'}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint("Unexpected error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unexpected error occurred"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Improved OTP dialog
  Future<String?> _showOtpDialog(BuildContext context) async {
    String smsCode = '';
    bool isCodeValid = false;

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('We sent a verification code to your phone'),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  smsCode = value;
                  isCodeValid = value.length == 6; // Assuming 6-digit OTP
                },
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter 6-digit code',
                ),
                maxLength: 6,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isCodeValid ? () {
                Navigator.of(context).pop(smsCode);
              } : null,
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to prompt the user for the OTP.
  Future<String> _getSmsCodeFromUser(BuildContext context) async {
    String smsCode = '';
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              smsCode = value;
            },
            decoration: const InputDecoration(
              labelText: 'OTP',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    return smsCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('User data not available')),
          );
        }

        // Create a Users object from the Firestore data
        final data = snapshot.data!.data()!;
        Users user = Users.fromJson(data);

        // Only update controllers if they haven't been modified yet
        if (_nameController.text.isEmpty) {
          _nameController.text = user.userName ?? '';
        }
        if (_emailController.text.isEmpty) {
          _emailController.text = user.userEmail ?? '';
        }
        if (_phoneController.text.isEmpty) {
          _phoneController.text = user.userPhone ?? '';
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pressable Circle Avatar
                  Center(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        showModalBottomSheet(context: context, builder: (BuildContext context) {
                          return CircleImageUploadOption(onImageSelected: _getImage);
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleImageAvatar(
                            imageUrl: user.userProfileURL,
                            size: 100,
                            onTap: () {

                            },
                          ),
                          Positioned(
                            bottom: 0,
                            right: 2,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  PhosphorIcons.camera(PhosphorIconsStyle.fill),
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name field
                  const Text(
                    "Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Enter your name',
                    validator: validateName,
                    isObscure: false,
                  ),
                  const SizedBox(height: 20),
                  // Email Text
                  Row(
                    children: [
                      const Text(
                        "Email",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4,),
                      verifiedStatusWidget(user.emailVerified!),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Enter your email',
                    enabled: false,
                    isObscure: false,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  // Mobile Number field
                  Row(
                    children: [
                      const Text(
                        "Mobile Number",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4,),
                      verifiedStatusWidget(user.phoneVerified!),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'Enter your mobile number',
                        isObscure: false,
                        validator: validatePhone,
                        inputType: TextInputType.phone,
                      ),

                      if (!user.phoneVerified!)
                        Positioned(
                        right: 0,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          onPressed: () {
                            print('Verify is clicked!');
                            // Implement your phone verification logic here.
                            // verifyAndActivatePhone(formatPhoneNumber(_phoneController.text.trim()), context);
                            PhoneAuthService().verifyAndActivatePhone(formatPhoneNumber(_phoneController.text.trim()), context);

                          },
                          child: const Text("Verify"),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).primaryColor,
              ),
              height: 60,
              child: TextButton(
                onPressed: () {
                  if(_nameController.text.trim() == user.userName && _phoneController.text.trim() == user.userPhone) {
                    Navigator.pop(context);
                  } else {
                    if(_formKey.currentState!.validate()){
                      _saveProfile();
                    }
                  }
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
