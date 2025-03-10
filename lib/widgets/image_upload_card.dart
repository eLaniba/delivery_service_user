import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ImageUploadCard extends StatelessWidget {
  final XFile? imageXFile;
  final VoidCallback onTap;
  final String label;

  const ImageUploadCard({
    Key? key,
    required this.imageXFile,
    required this.onTap,
    required this.label, // e.g. "DTI/SEC", "Mayor's Permit", "BIR"
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color gray4 = Colors.grey;

    return InkWell(
      onTap: onTap,
      customBorder: CircleBorder(),
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Show dashed border only if no image is selected
          border: imageXFile == null
              ? DashedBorder.fromBorderSide(
            side: BorderSide(
              color: gray4,
              width: 2,
            ),
            dashLength: 6,
          )
              : null,
        ),
        child: imageXFile == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.image(PhosphorIconsStyle.regular),
              size: 32,
              color: gray4,
            ),
            Text(
              label, // <-- Display the label you pass in
              style: TextStyle(color: gray4),
              textAlign: TextAlign.center,
            ),
          ],
        )
            : ClipOval(
          child: Image.file(
            File(imageXFile!.path),
            fit: BoxFit.cover,
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}
