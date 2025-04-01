import 'package:delivery_service_user/models/address.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShowMapDialog extends StatelessWidget {
  final Address address;

  const ShowMapDialog({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    final LatLng location = LatLng(
      address.location!.latitude,
      address.location!.longitude,
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: Text(address.addressEng ?? 'Address', style: TextStyle(fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis,),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('addressLocation'),
              position: location,
              infoWindow: InfoWindow(title: address.addressEng),
            ),
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}