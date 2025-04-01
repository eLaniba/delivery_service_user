import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  Future<void> verifyAndActivatePhone(String phoneNumber, BuildContext context) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user signed in")),
      );
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _linkPhoneNumber(user, credential, context);
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}"), backgroundColor: Colors.red),
          );
        },
        codeSent: (String verificationId, int? resendToken) async {
          _verificationId = verificationId;
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
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _linkPhoneNumber(User user, PhoneAuthCredential credential, BuildContext context) async {
    try {
      UserCredential userCredential = await user.linkWithCredential(credential);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'phoneVerified': true,
        'userPhone': userCredential.user?.phoneNumber,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone verified successfully!"), backgroundColor: Colors.green),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}"), backgroundColor: Colors.red),
      );
    }
  }

  Future<String?> _showOtpDialog(BuildContext context) async {
    String smsCode = '';
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the verification code sent to your phone'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  smsCode = value;
                },
                decoration: const InputDecoration(labelText: 'OTP', hintText: '6-digit code'),
                maxLength: 6,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(smsCode);
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }
}
