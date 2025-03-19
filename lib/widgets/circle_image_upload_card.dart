
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CircleImageUploadCard extends StatelessWidget {
  final XFile? imageXFile;
  final VoidCallback onTap;
  final String label;

  const CircleImageUploadCard({
    Key? key,
    required this.imageXFile,
    required this.onTap,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: imageXFile == null
      // If there's NO image, show the dotted border + label
          ? DottedBorder(
        borderType: BorderType.Circle,
        dashPattern: const [6, 6], // dash length, gap length
        color: Colors.grey,        // border color
        strokeWidth: 2,
        child: SizedBox(
          width: 100,
          height: 100,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIcons.image(PhosphorIconsStyle.regular),
                  size: 32,
                  color: Colors.grey,
                ),
                // const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      )
      // If there's an image, clip it into a circle
          : ClipOval(
        child: Image.file(
          File(imageXFile!.path),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
