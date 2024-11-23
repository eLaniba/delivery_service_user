import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/authentication/login_remake.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/services/geopoint_json.dart';
import 'package:delivery_service_user/widgets/custom_text_field.dart';
import 'package:delivery_service_user/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_user/widgets/error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_screen.dart';

import 'package:delivery_service_user/widgets/loading_dialog.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  Position? position;
  List<Placemark>? placeMarks;
  GeoPoint? geoPoint;

  String completeAddress = "";

  getCurrentLocation() async {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position newPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      position = newPosition;
      placeMarks = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );

      geoPoint = GeoPoint(position!.latitude, position!.longitude);

      Placemark pMark = placeMarks![1];

      completeAddress = '${pMark.street}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.country}';

      locationController.text = completeAddress;
    } catch (e) {
      rethrow;
    }
  }

  registerNow() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Creating account");
      },
    );

    //Authenticate User and Save Data to Firestore if != null
    authenticateUserAndSignup();
  }

  void authenticateUserAndSignup() async {
    User? currentUser;
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });

    if(currentUser != null) {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send the user to homePage
        Route newRoute = MaterialPageRoute(builder: (c) => MainScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("users").doc(currentUser.uid).set({
      "userID": currentUser.uid,
      "userEmail": currentUser.email,
      "userName": nameController.text.trim(),
      "userPhone": phoneController.text.trim(),
      "status": "approved",
      //temporarily add the Address info here instead of as a collection
      "userAddress": locationController.text.trim(),
      "userLocation": geoPoint,
    });

    //Setting up default address' reference
    CollectionReference addressCollection = FirebaseFirestore.instance.collection("users").doc(currentUser.uid).collection("address");

    //Add address, latitude, and longitude (will be added 2nd semester)
    await addressCollection.add({
      "addressEng": locationController.text,
      "location": geoPoint,
    });

    //Save data locally
    String locationString = geoPointToJson(geoPoint!);
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("phone", phoneController.text.trim());
    await sharedPreferences!.setString("address", completeAddress);
    await sharedPreferences!.setString("location", locationString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Create an account,",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40.0,),
                  child: Column(
                    children: [
                      CustomTextField(
                        labelText: 'Name',
                        controller: nameController,
                        isObscure: false,
                        validator: validateName,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
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
                        height: 16,
                      ),
                      CustomTextField(
                          labelText: 'Confirm password',
                          controller: confirmPasswordController,
                          isObscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty || value.trim() != passwordController.text.trim()) {
                              return 'Password did not match';
                            }
                            return null;
                          }
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomTextField(
                        labelText: 'Phone',
                        controller: phoneController,
                        isObscure: false,
                        validator: validatePhone,
                      ),
                      const SizedBox(
                        height: 16,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              labelText: 'Your location',
                              controller: locationController,
                              isObscure: false,
                              enabled: true,
                              validator: validateLocation,
                            ),
                          ),

                          IconButton(
                            onPressed: getCurrentLocation,
                            icon: const Icon(Icons.location_on),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_formKey.currentState!.validate()) {
                              //Register
                              registerNow();
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                          padding: const EdgeInsets.only(left: 64, right: 64),
                        ),
                        child: const Text("Register"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              //Already have an account? Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      // Add your navigation or action here for Sign Up
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginRemake()),
                      );
                    },
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Sign In',),
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
