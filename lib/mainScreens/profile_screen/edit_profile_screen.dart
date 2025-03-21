import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/users.dart';
import 'package:delivery_service_user/widgets/custom_text_field.dart';
import 'package:delivery_service_user/widgets/status_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
      'userName': _nameController.text,
      'userEmail': _emailController.text,
      'userPhone': _phoneController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> verifyAndActivatePhone(String phoneNumber) async {
    final User? user = firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('No user signed in');
      return;
    }

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatic verification: directly link the phone credential
        try {
          UserCredential userCredential = await user.linkWithCredential(credential);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'phoneVerified': true,
            'userPhone': userCredential.user?.phoneNumber,
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
              content: Text("Phone verified successfully!"),
                backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          debugPrint("Error during auto-verification: $e");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("Verification failed: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}"))
        );
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Manual verification: prompt user to enter the OTP
        String smsCode = await _getSmsCodeFromUser(context);
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: smsCode);
        try {
          UserCredential userCredential = await user.linkWithCredential(credential);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'phoneVerified': true,
            'userPhone': userCredential.user?.phoneNumber,
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Phone verified successfully!"))
          );
        } catch (e) {
          debugPrint("Error during linking: $e");
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error linking phone number: $e"))
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint("Code auto-retrieval timeout");
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pressable Circle Avatar
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Handle avatar tap, e.g. open image picker
                      debugPrint("Avatar tapped");
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: user.userProfileURL != null &&
                          user.userProfileURL!.isNotEmpty
                          ? NetworkImage(user.userProfileURL!)
                          : const AssetImage('assets/avatar.png')
                      as ImageProvider,
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
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Enter your mobile number',
                  isObscure: false,
                  inputType: TextInputType.phone,
                  suffixIcon: user.phoneVerified == false
                      ? TextButton(
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          onPressed: () {
                            print('Verify is clicked!');
                            // Implement your phone verification logic here.
                            verifyAndActivatePhone(_phoneController.text.trim());
                          },
                          child: const Text("Verify"),
                        )
                      : null,
                ),
              ],
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
                onPressed: _saveProfile,
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
