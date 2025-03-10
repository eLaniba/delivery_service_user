import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/services/geopoint_json.dart';
import 'package:delivery_service_user/widgets/custom_text_field.dart';
import 'package:delivery_service_user/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';  // Import Geolocator package
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddNewAddressScreen extends StatefulWidget {
  @override
  _AddNewAddressScreenState createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController locationController = TextEditingController();

  GoogleMapController? _mapController;

  LatLng? _currentPosition;  // Use nullable type for _currentPosition

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Method to fetch current location using Geolocator
  Future<void> _getCurrentLocation() async {
    Position? position;
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, you can show a message or handle accordingly
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always || permission != LocationPermission.whileInUse) {
        // Permissions not granted, handle accordingly
        return;
      }
    }

    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position newPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      setState(() {
        _currentPosition = LatLng(newPosition.latitude, newPosition.longitude);
      });

      if (_currentPosition != null) {
        _getAddressFromLatLng(_currentPosition!); // Fetch address when position is available
      }

    } catch(e) {
      rethrow;
    }
  }

  // Method to get the address from latitude and longitude
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark pMark = placemarks[1];
        setState(() {
          locationController.text = '${pMark.street}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.country}';
        });
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  addNewAddressToFirestore() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Adding address");
      },
    );

    if (_currentPosition == null) {
      // Handle case if current position is still null
      Navigator.of(context).pop();
      return;
    }

    GeoPoint newLocation = GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude);

    CollectionReference addressCollection = firebaseFirestore
        .collection('users')
        .doc('${sharedPreferences!.getString('uid')}')
        .collection('address');

    DocumentReference addressDoc = await addressCollection.add({
      'addressEng': locationController.text,
      'location': newLocation,
    });

    await addressDoc.update({
      'addressID': addressDoc.id,
    });

    // Pop the loading dialog
    Navigator.of(context).pop();
    // Pop the Add New Address Screen
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Pick a Location"),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick a Location"),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container for Google Map with a border
            Container(
              height: 300, // Set height for the map container
              margin: const EdgeInsets.all(16.0), // Margin around the container
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0), // Border for the container
                borderRadius: BorderRadius.circular(8.0), // Rounded corners for the border
              ),
              child: Stack(
                children: [
                  // Google Map wrapped in ClipRRect to follow container's curve
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0), // Apply the same rounded corners
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,  // Use _currentPosition here
                        zoom: 16.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      onCameraMove: (CameraPosition position) {
                        setState(() {
                          _currentPosition = position.target;
                        });
                        // _getAddressFromLatLng(position.target); // Update address as map moves
                      },
                      onCameraIdle: () {
                        if (_currentPosition != null) {
                          _getAddressFromLatLng(_currentPosition!);
                        }
                      },
                      myLocationEnabled: false, // Disable the blue dot
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                  ),
                  // Center pin icon
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, -25),
                      child: const Icon(
                        Icons.location_pin,
                        size: 50.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    PhosphorIcons.info(PhosphorIconsStyle.regular),
                    color: Colors.blue, // Choose the color you want for the icon
                    size: 24.0, // Set the size for the icon
                  ),
                  const SizedBox(width: 8.0), // Add some space between the icon and the text
                  const Flexible(
                    child: Text(
                      'The address might not be fully accurate. Please review and edit the address below.',
                      style: TextStyle(
                        fontSize: 14.0, // Set the font size
                        color: Colors.grey, // Set the text color
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomTextField(
                  labelText: 'Address',
                  controller: locationController,
                  isObscure: false,
                  enabled: true,
                  validator: validateLocationNewAddress,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).primaryColor,
          ),
          height: 60,
          child: TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                addNewAddressToFirestore();
              }
            },
            child: const Text(
              'Save Address',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
