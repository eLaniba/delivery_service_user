import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Example color constant. Update or remove as needed.
final Color white80 = Colors.white.withOpacity(0.8);

class ImageAvatar extends StatelessWidget {
  final String? imageUrl;

  const ImageAvatar({
    Key? key,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: SizedBox(
                  height: 200,
                  child: Center(
                    child: Icon(
                      PhosphorIcons.image(PhosphorIconsStyle.fill),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: white80,
                child: Icon(
                  PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 48,
                ),
              ),
            )
          : Container(
              color: white80,
              child: Icon(
                PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                color: Colors.white,
              ),
            ),
    );
  }
}
