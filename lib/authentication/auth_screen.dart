import 'package:delivery_service_user/authentication/login.dart';
import 'package:delivery_service_user/authentication/register.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    // Check if the user is already signed in
    checkUserStatus();
  }

  // Check user authentication status
  Future<void> checkUserStatus() async {
    User? user = firebaseAuth.currentUser;

    if (user != null) {
      // If the user is already logged in, navigate to the MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // return DefaultTabController(
    //   length: 2, // Number of tabs
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: const Text('User'),
    //       centerTitle: true,
    //       bottom: const TabBar(
    //         tabs: [
    //           Tab(icon: Icon(Icons.login),),
    //           Tab(icon: Icon(Icons.person_add_alt_1_outlined),),
    //         ],
    //       ),
    //     ),
    //     body: const TabBarView(
    //       children: [
    //         Login(),
    //         Register(),
    //       ],
    //     ),
    //   ),
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text('HELLO'),
      ),
    );
  }
}
