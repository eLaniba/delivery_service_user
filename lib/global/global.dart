import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? sharedPreferences;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
FirebaseStorage firebaseStorage = FirebaseStorage.instance;
FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

//Colors temporary
const Color white80 = Color.fromARGB(255, 238, 238, 238);
const Color white70 = Color.fromARGB(255, 224, 224, 224);
const Color grey50 = Color.fromARGB(255, 189, 195, 199);
const Color grey20 = Color.fromARGB(255, 151, 154, 154);

//From Figma
const Color gray = Color.fromARGB(255, 142, 142, 147);
const Color gray5 = Color.fromARGB(255, 229, 229, 234);
const Color gray4 = Color(0xFFD1D1D6);

String apiKey = 'AIzaSyDN4P2wLPNtH9NqROqux8NVc2XaHGViO2U';
