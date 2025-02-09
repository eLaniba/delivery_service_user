import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/authentication/register.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/services/auth_service.dart';
import 'package:delivery_service_user/services/geopoint_json.dart';
import 'package:delivery_service_user/widgets/confirmation_dialog.dart';
import 'package:delivery_service_user/widgets/custom_text_field.dart';
import 'package:delivery_service_user/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_user/widgets/error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'full_registration_page.dart';

class ExistingAccountLoginPage extends StatefulWidget {
  final String email;
  const ExistingAccountLoginPage({Key? key, required this.email}) : super(key: key);

  @override
  _ExistingAccountLoginPageState createState() => _ExistingAccountLoginPageState();
}

class _ExistingAccountLoginPageState extends State<ExistingAccountLoginPage> {
  //AuthService class (see services/auth_service.dart)
  final AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoggingIn = false;

  Future<void> _login() async {
    setState(() {
      _isLoggingIn = true;
    });
    try {
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: widget.email,
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        //Check if user exist in the Firestore
        final snapshot = await firebaseFirestore.collection('users').doc(user.uid).get();
        if(snapshot.exists) {
          validateUser(user);
        } else {
          // Navigate to Registration Page.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Register(email: widget.email),
            ),
          );
        }


      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login error: ${e.message}"),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  Future<void> validateUser(User currentUser) async {
    try{
      //Fetch user data from Firestore
      final snapshot = await firebaseFirestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if(snapshot.exists) {
        print('//Assign snapshot to userData');
        //Assign snapshot to userData
        final userData = snapshot.data();
        //Getting the GeoPoint value from the userLocation key
        final GeoPoint userLocation = userData!['userLocation'];
        //Convert GeoPoint to JSON string to be saved in sharedPreferences
        String userLocationString = geoPointToJson(userLocation);

        //Saving data locally using sharedPreferences
        await sharedPreferences!.setString('uid', currentUser.uid);
        await sharedPreferences!.setString('name', userData['userName']);
        await sharedPreferences!.setString('email', userData['userEmail']);
        await sharedPreferences!.setString('phone', userData['userPhone']);
        await sharedPreferences!.setString('address', userData['userAddress']);
        await sharedPreferences!.setString('location', userLocationString);
        //Saving login state locally so user don't have to re-login if the app exit
        await _authService.setLoginState(true);

        //Close the Loading Dialog
        Navigator.pop(context);
        // Navigate to the main screen if the login is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        //If currentUser does not exist in the Firestore
        firebaseAuth.signOut();
        //Close the Loading Dialog
        Navigator.pop(context);
        //Show an Error Dialog
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "No account exist",
              );
            }
        );
      }
    } catch(error) {
      firebaseAuth.signOut();
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Login failed",
            );
          }
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

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
          title: const Text("Reset your password"),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //Image
              Image.asset(
                'assets/verify_email_sent.png',
                height: 200,
                width: 200,
              ),
              //User email
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Text("Check your email for the reset password link,\nthen enter your new password below.", textAlign: TextAlign.center,),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    //Password Text Field
                    CustomTextField(
                      labelText: 'Enter your new password',
                      controller: _passwordController,
                      isObscure: true,
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 16),
                    //Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if(_formKey.currentState!.validate()) {
                            _isLoggingIn ? null : _login();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: _isLoggingIn
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.inversePrimary,
                                strokeWidth: 3,
                              ),
                        )
                            : const Text("Continue"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
