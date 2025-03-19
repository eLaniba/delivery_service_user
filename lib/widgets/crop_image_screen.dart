import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

class CropImageScreen extends StatefulWidget {
  final Uint8List imageData;
  final double aspectRatio; // e.g. 8.5/13, 1.0, 16/9

  const CropImageScreen({
    Key? key,
    required this.imageData,
    required this.aspectRatio,
  }) : super(key: key);

  @override
  _CropImageScreenState createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final CropController _cropController = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Image"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Crop(
        controller: _cropController,
        image: widget.imageData,
        aspectRatio: widget.aspectRatio,
        interactive: true,
        cornerDotBuilder: (size, alignment) => const SizedBox.shrink(),
        onCropped: (result) {
          if (result is CropSuccess) {
            debugPrint("Crop successful, returning cropped data");
            Navigator.pop(context, result.croppedImage);
          }
        },
        withCircleUi: false,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).primaryColor,
          ),
          height: 60,
          child: _isCropping
              ? const Center(child: CircularProgressIndicator(color: Colors.white,))
              : TextButton(
            onPressed: () {
              setState(() {
                _isCropping = true;
              });
              _cropController.crop();
            },
            child: const Text(
              'Crop',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
