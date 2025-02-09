import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/authentication/login_remake.dart';
import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/services/geopoint_json.dart';
import 'package:delivery_service_user/widgets/confirmation_dialog.dart';
import 'package:delivery_service_user/widgets/custom_text_field.dart';
import 'package:delivery_service_user/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_user/widgets/error_dialog.dart';
import 'package:delivery_service_user/widgets/sign_up_agreement.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:delivery_service_user/global/global.dart';

import 'package:delivery_service_user/widgets/loading_dialog.dart';

class Register extends StatefulWidget {
  String? email;

  Register({super.key, this.email});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  Position? position;
  List<Placemark>? placeMarks;
  GeoPoint? geoPoint;

  String completeAddress = "";

  // Add the state variable to track password visibility
  bool _isPasswordHidden = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController.text = widget.email!;
  }

  // getCurrentLocation() async {
  //   try {
  //     const LocationSettings locationSettings = LocationSettings(
  //       accuracy: LocationAccuracy.high,
  //       distanceFilter: 100,
  //     );
  //
  //     Position newPosition = await Geolocator.getCurrentPosition(
  //       locationSettings: locationSettings,
  //     );
  //
  //     position = newPosition;
  //     placeMarks = await placemarkFromCoordinates(
  //       position!.latitude,
  //       position!.longitude,
  //     );
  //
  //     geoPoint = GeoPoint(position!.latitude, position!.longitude);
  //
  //     Placemark pMark = placeMarks![1];
  //
  //     completeAddress = '${pMark.street}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.country}';
  //
  //     locationController.text = completeAddress;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  signUp() async {
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
    DocumentReference addressDoc = await addressCollection.add({
      "addressEng": locationController.text,
      "location": geoPoint,
    });

    await addressDoc.update({
      'addressID': addressDoc.id,
    });

    //Save data locally
    String locationString = geoPointToJson(geoPoint!);
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("phone", phoneController.text.trim());
    await sharedPreferences!.setString("addressID", addressDoc.id);
    await sharedPreferences!.setString("address", completeAddress);
    await sharedPreferences!.setString("location", locationString);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show a warning dialog when the user tries to leave.
        bool? shouldLeave = await ConfirmationDialog.show(
          context,
          'Are you sure you want to leave this page? Your progress may be lost.',
        );
        // If the user didn't confirm, don't allow the page to pop.
        return shouldLeave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create new account"),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Image
                Image.asset(
                  'assets/create_account.png',
                  height: 200,
                  width: 200,
                ),
                Text(
                  "${widget.email}",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Full Name Text
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      //Full Name Text Field
                      CustomTextField(
                        labelText: 'Full name',
                        controller: nameController,
                        isObscure: false,
                        validator: validateName,
                      ),
                      const SizedBox(height: 8),
                      //Mobile Number Text
                      // const Text(
                      //   'Mobile Number',
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Mobile Number',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8,),
                          InkWell(
                            onTap: () {
                              // Hide any current banner if it's already showing.
                              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                              // Show a MaterialBanner at the top.
                              ScaffoldMessenger.of(context).showMaterialBanner(
                                MaterialBanner(
                                  content: const Text(
                                    'To verify your account, make sure you use a valid mobile number.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.blue,
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                                      },
                                      child: const Text(
                                        'DISMISS',
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: SizedBox(
                              child: PhosphorIcon(
                                PhosphorIcons.info(PhosphorIconsStyle.regular),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      //Mobile Number Text Field
                      CustomTextField(
                        labelText: '09104455666',
                        controller: phoneController,
                        isObscure: false,
                        validator: validatePhone,
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
                        isObscure: _isPasswordHidden,
                        validator: validatePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordHidden = !_isPasswordHidden;
                            });
                          },
                          icon: PhosphorIcon(
                            _isPasswordHidden ? PhosphorIcons.eyeSlash(PhosphorIconsStyle.bold)
                            : PhosphorIcons.eye(PhosphorIconsStyle.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // PhosphorIcon(PhosphorIcons.info(PhosphorIconsStyle.regular),),
                      SignUpAgreement(onTermsTap: (){}, onPrivacyTap: (){}),
                      const SizedBox(height: 8),

                      //Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_formKey.currentState!.validate()) {
                                //Register
                                signUp();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14,),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text("Sign Up"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
