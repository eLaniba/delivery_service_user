import 'package:delivery_service_user/authentication/auth_screen_remake.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/services/auth_service.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthService _authService = AuthService();

  void Logout() async {
    await firebaseAuth.signOut();
    // await sharedPreferences!.clear();
    await _authService.setLoginState(false);
    print('DONE');


    print('pops');
    // Navigate to the Auth Screen if the logout was successful
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreenRemake()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: Logout,
        child: const Text('Logout'),),
    );
  }
}
