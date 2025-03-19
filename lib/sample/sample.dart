import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class StoreCard extends StatelessWidget {
  final Stores store;
  final VoidCallback? onTap;

  const StoreCard({
    Key? key,
    required this.store,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // Container can have a subtle shadow, borders, or be fully transparent
      child: Container(
        // Example: subtle shadow and rounded corners
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Material(
          // Make the background transparent so only the white container
          // for text stands out.
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: ListTile(
            // Keep tileColor or other background to transparent
            tileColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(8),
            leading: _buildCircleAvatar(context),
            // Place storeName, phone, address in a white container
            title: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name (bold)
                  Text(
                    store.storeName ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Phone
                  Text(
                    reformatPhoneNumber(store.storePhone ?? ''),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Address
                  Text(
                    store.storeAddress ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a CircleAvatar with CachedNetworkImage and Shimmer
  Widget _buildCircleAvatar(BuildContext context) {
    final imageUrl = store.storeProfileURL;

    return SizedBox(
      width: 50,
      height: 50,
      child: imageUrl == null
          ? CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(
          PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
          color: Colors.grey[500],
        ),
      )
          : CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Icon(
              PhosphorIcons.image(PhosphorIconsStyle.fill),
              color: Colors.grey[500],
            ),
          ),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(
            PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }
}
