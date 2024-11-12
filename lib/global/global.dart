import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? sharedPreferences;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

//Colors temporary
Color white80 = const Color.fromARGB(255, 238, 238, 238);
Color white70 = const Color.fromARGB(255, 224, 224, 224);
Color grey50 = const Color.fromARGB(255, 189, 195, 199);