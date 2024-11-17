import 'package:delivery_service_user/authentication/login_remake.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthScreenRemake extends StatefulWidget {
  const AuthScreenRemake({super.key});

  @override
  State<AuthScreenRemake> createState() => _AuthScreenRemakeState();
}

class _AuthScreenRemakeState extends State<AuthScreenRemake> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authService.isLoggedIn(),
      builder: (context, snapshot) {
        if(snapshot.hasData && snapshot.data == true) {
          return MainScreen();
        } else {
          return LoginRemake();
        }
      },
    );
  }
}
