import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FullRegistrationPage extends StatelessWidget {
  final User user;
  const FullRegistrationPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace this with your full registration form.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Registration"),
      ),
      body: Center(
        child: Text("Welcome, ${user.email}.\nComplete your registration here."),
      ),
    );
  }
}
