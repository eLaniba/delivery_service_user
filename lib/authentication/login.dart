import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/authentication/auth_screen.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_screen.dart';
import 'package:delivery_service_user/services/geopoint_json.dart';
import 'package:delivery_service_user/widgets/custom_text_field.dart';
import 'package:delivery_service_user/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_user/widgets/error_dialog.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  loginNow() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Checking credentials");
      },
    );

    User? currentUser;
    await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
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
      Navigator.pop(context);
      readAndSetDataLocally(currentUser!);
    }
  }

  Future readAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        // Retrieve the GeoPoint
        GeoPoint userLocation = snapshot.data()!["userLocation"];

        // Convert GeoPoint to JSON string
        String locationString = geoPointToJson(userLocation);

        await sharedPreferences!.setString("uid", currentUser.uid);
        await sharedPreferences!.setString("name", snapshot.data()!["userName"]);
        await sharedPreferences!.setString("email", snapshot.data()!["userEmail"]);
        await sharedPreferences!.setString("phone", snapshot.data()!["userPhone"]);
        await sharedPreferences!.setString("address", snapshot.data()!["userAddress"]);
        await sharedPreferences!.setString("location", locationString);

        // Navigate to the main screen if the login is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );

      } else {
        firebaseAuth.signOut();
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                  message: "Login failed",
              );
            }
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/splash_image.png'),
            const Text(
              "Welcome,",
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 16,
            ),

            //sample
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: 'Email',
                      controller: emailController,
                      isObscure: false,
                      validator: validateEmail,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomTextField(
                      labelText: 'Password',
                      controller: passwordController,
                      isObscure: true,
                      validator: validatePassword,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          //Login
                          loginNow();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                        padding: const EdgeInsets.only(left: 64, right: 64),
                      ),
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
