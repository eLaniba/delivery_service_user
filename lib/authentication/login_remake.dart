import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/authentication/new_signup/email_verification_page.dart';
import 'package:delivery_service_user/authentication/register.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/services/auth_service.dart';
import 'package:delivery_service_user/services/geopoint_json.dart';
import 'package:delivery_service_user/widgets/custom_text_field.dart';
import 'package:delivery_service_user/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_user/widgets/error_dialog.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginRemake extends StatefulWidget {
  const LoginRemake({super.key});

  @override
  State<LoginRemake> createState() => _LoginRemakeState();
}

class _LoginRemakeState extends State<LoginRemake> {
  //AuthService class (see services/auth_service.dart)
  AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    //Show Loading Dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Checking credentials");
      },
    );

    // try{
    //   //Attempt login
    //   final authResult = await firebaseAuth.signInWithEmailAndPassword(
    //     email: emailController.text.trim(),
    //     password: passwordController.text.trim(),
    //   );
    //
    //   //Assign the user to use for validation
    //   final currentUser = authResult.user;
    //
    //   if(currentUser != null) {
    //     print('//Validate User');
    //     //Validate User
    //     validateUser(currentUser);
    //   } else {
    //     print('Error null');
    //   }
    // } catch(e) {
    //   //Closes the loading dialog
    //   Navigator.pop(context);
    //
    //   //Show Error Dialog
    //   showDialog(
    //     context: context,
    //     builder: (error) {
    //       return ErrorDialog(
    //         message: error.toString(),
    //       );
    //     },
    //   );
    // }

    User? currentUser;
    //Logging in to Firebase Auth
    await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      //Assign
      currentUser = auth.user!;
    }).catchError((error) {
      //Handle Errors by Showing ErrorDialog
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: error.message.toString(),
          );
        },
      );
    });

    if(currentUser != null) {
      validateUser(currentUser!);
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
        final userData = snapshot.data();
        //Getting the GeoPoint value from the userLocation key
        final GeoPoint userLocation = userData!['userLocation'];
        //Convert GeoPoint to JSON string to be saved in sharedPreferences
        String userLocationString = geoPointToJson(userLocation);

        //Saving data locally using sharedPreferences
        await sharedPreferences!.setString("profileURL", userData['userProfileURL']);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Center(child: Text('Welcome!', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary), textAlign: TextAlign.center,)),
        // backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/splash_image.png',
                height: 200,
                width: 200,
              ),
              // const Text(
              //   "Welcome",
              //   style: TextStyle(
              //     fontSize: 24,
              //   ),
              // ),
              // const SizedBox(height: 8),

              //sample
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Email Text
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      //Email Text Field
                      CustomTextField(
                        labelText: 'example@gmail.com',
                        controller: emailController,
                        isObscure: false,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 8),
                      //Password Text
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      //Password Text Field
                      CustomTextField(
                        labelText: 'Password',
                        controller: passwordController,
                        isObscure: true,
                        validator: validatePassword,
                      ),
                      //Forgot password?
                      TextButton(
                        onPressed: () {
                          // Add your navigation or action here for Sign Up
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Forgot password?'),
                      ),
                      const SizedBox(height: 12),

                      //Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              //Login
                              login();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14,),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text("Login"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              //Don't have an account? Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Add your navigation or action here for Sign Up
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Sign Up',),
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}
