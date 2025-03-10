import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/authentication/new_signup/add_address_screen.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/services/auth_service.dart';
import 'package:delivery_service_user/services/geopoint_json.dart';
import 'package:delivery_service_user/services/image_picker_service.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:delivery_service_user/widgets/confirmation_dialog.dart';
import 'package:delivery_service_user/widgets/custom_text_field.dart';
import 'package:delivery_service_user/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_user/widgets/error_dialog.dart';
import 'package:delivery_service_user/widgets/image_upload_card.dart';
import 'package:delivery_service_user/widgets/image_upload_option.dart';
import 'package:delivery_service_user/widgets/sign_up_agreement.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';

class Register extends StatefulWidget {
  final String? email;
  final User user;

  const Register({super.key, this.email, required this.user});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //AuthService class (see services/auth_service.dart)
  final AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  XFile? _imgXFile;
  String imageValidation = "";

  TextEditingController nameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Position? position;
  List<Placemark>? placeMarks;

  String? address;
  GeoPoint? geoPoint;

  // Add the state variable to track password visibility
  bool _isPasswordHidden = true;

  // Timer variables for expiration
  late Timer _expirationTimer;
  int _remainingSeconds = 300; // Set your expiration time in seconds

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email!;
    // _startExpirationTimer();
  }

  @override
  void dispose() {
    _expirationTimer.cancel();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  signUp() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Creating account");
      },
    );

    // Authenticate User and Save Data to Firestore if != null
    authenticateUserAndSignup();
  }

  void authenticateUserAndSignup() async {
    User? currentUser;
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });

    if (currentUser != null) {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        // Send the user to homePage
        Route newRoute = MaterialPageRoute(builder: (c) => const MainScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    showDialog(
        context: context,
        builder: (c) {
          return const LoadingDialog(
            message: 'Signing you in',
          );
        });

    final String userPhone = formatPhoneNumber(phoneController.text.trim());
    final String userName  = capitalizeEachWord(nameController.text.trim());

    try {
      await currentUser.updatePassword(passwordController.text.trim());

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .set({
        "userID": currentUser.uid,
        "userEmail": currentUser.email,
        "userName": userName,
        "userPhone": userPhone,
        "status": "pending",
        // Temporarily add the Address info here instead of as a collection
        "userAddress": address,
        "userLocation": geoPoint,
        // Bool for Approval in Admin
        "emailVerified": true,
        "phoneVerified": false,
        "idVerified": false,
      });

      // Setting up default address' reference
      CollectionReference addressCollection = FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .collection("address");

      // Add address, latitude, and longitude
      DocumentReference addressDoc = await addressCollection.add({
        "addressEng": address,
        "location": geoPoint,
      });

      await addressDoc.update({
        'addressID': addressDoc.id,
      });

      // Save geoPoint data locally
      String locationString = geoPointToJson(geoPoint!);

      await sharedPreferences!.setString("uid", currentUser.uid);
      await sharedPreferences!.setString("name", userName);
      await sharedPreferences!.setString("email", currentUser.email.toString());
      await sharedPreferences!.setString("phone", userPhone);
      await sharedPreferences!.setString("address", address!);
      await sharedPreferences!.setString("location", locationString);

      print('REGISTER SUCCESSFUL, PUSH YOU TO THE APP');
      // Saving login state locally so user don't have to re-login if the app exits
      await _authService.setLoginState(true);

      // Close the Loading Dialog
      Navigator.pop(context);
      // Navigate to the main screen if the login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      // Close the Loading Dialog
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          print(e);
          return ErrorDialog(message: "An unexpected error occurred: $e");
        },
      );
    }
  }

  // Future<void> _getImage(ImageSource source) async {
  //   XFile? imageXFile;
  //
  //   imageXFile = await ImagePickerService().pickCropImage(
  //     cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
  //     imageSrouce: source,
  //   );
  //
  //   if(imageXFile != null) {
  //     setState(() {
  //       imageValidation = '';
  //       _imgXFile = imageXFile;
  //     });
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show a warning dialog when the user tries to leave.
        bool? shouldLeave = await ConfirmationDialog.show(
          context,
          'Are you sure you want to leave this page? Your progress may be lost.',
        );
        // If the user didn't confirm, don't allow the page to pop.
        return shouldLeave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create new account"),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Image
                // Image.asset(
                //   'assets/create_account.png',
                //   height: 200,
                //   width: 200,
                // ),
                //Image Container
                // ImageUploadCard(
                //     imageXFile: _imgXFile,
                //     onTap: () {
                //       showModalBottomSheet(context: context, builder: (BuildContext context) {
                //         return ImageUploadOption(onImageSelected: _getImage);
                //       });
                //     },
                //     label: 'Upload your profile picture'),
                const SizedBox(height: 8,),
                //Image Validation Text
                Text(
                  imageValidation,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error
                  ),
                ),
                Text(
                  "${widget.email}",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name Text
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Full Name Text Field
                      CustomTextField(
                        labelText: 'Full name',
                        controller: nameController,
                        isObscure: false,
                        validator: validateName,
                      ),
                      const SizedBox(height: 8),
                      // Mobile Number Text + Icon Helper
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Mobile Number',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              // Hide any current banner if it's already showing.
                              ScaffoldMessenger.of(context)
                                  .hideCurrentMaterialBanner();
                              // Show a MaterialBanner at the top.
                              ScaffoldMessenger.of(context)
                                  .showMaterialBanner(
                                MaterialBanner(
                                  content: const Text(
                                    'To verify your account, make sure you use a valid mobile number.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.blue,
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentMaterialBanner();
                                      },
                                      child: const Text(
                                        'DISMISS',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: SizedBox(
                              child: PhosphorIcon(
                                PhosphorIcons.info(
                                    PhosphorIconsStyle.regular),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Mobile Number Text Field
                      CustomTextField(
                        labelText: '+639102445676',
                        controller: phoneController,
                        isObscure: false,
                        validator: validatePhone,
                        prefixText: '+63',
                      ),
                      const SizedBox(height: 8),
                      // Address Text
                      const Text(
                        'Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Address Text Field
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => AddAddressScreen()));

                          if (result != null) {
                            setState(() {
                              address =
                                  result['addressEng'].toString().trim();
                              addressController.text = address!;
                              geoPoint = result['location'];
                            });
                          }
                        },
                        child: IgnorePointer(
                          child: CustomTextField(
                            labelText: 'Set up your address',
                            controller: addressController,
                            isObscure: false,
                            validator: validateLocation,
                          ),
                        ),
                      ),
                      // Password Text
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Password Text Field
                      CustomTextField(
                        labelText: 'Password',
                        controller: passwordController,
                        isObscure: _isPasswordHidden,
                        validator: validatePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordHidden = !_isPasswordHidden;
                            });
                          },
                          icon: PhosphorIcon(
                            _isPasswordHidden
                                ? PhosphorIcons.eyeSlash(
                                PhosphorIconsStyle.bold)
                                : PhosphorIcons.eye(
                                PhosphorIconsStyle.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SignUpAgreement(
                          onTermsTap: () {}, onPrivacyTap: () {}),
                      const SizedBox(height: 8),
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Signup
                              saveDataToFirestore(widget.user);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Theme.of(context).colorScheme.primary,
                            foregroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text("Sign Up"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A simple screen to show when the session expires.
class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.smileyXEyes(PhosphorIconsStyle.light),
              color: Theme.of(context).primaryColor,
              size: 64,
            ),
            const Text(
              "Your session has expired.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Theme.of(context).colorScheme.primary,
                foregroundColor:
                Theme.of(context).colorScheme.inversePrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {
                // Navigate back to a relevant screen, such as the signup screen.
                Navigator.pop(context);
              },
              child: const Text("Back to Login"),
            )
          ],
        ),
      ),
    );
  }
}
