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
      child: Container(
        // margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          // Subtle shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Network image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: (store.storeCoverURL != null)
                    ? CachedNetworkImage(
                        imageUrl: store.storeCoverURL!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: SizedBox(
                            height: 120,
                            child: Center(
                              child: PhosphorIcon(
                                  PhosphorIcons.image(PhosphorIconsStyle.fill)),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.red,
                          child: PhosphorIcon(
                            PhosphorIcons.imageBroken(PhosphorIconsStyle.regular),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.red,
                        child: PhosphorIcon(
                          PhosphorIcons.imageBroken(PhosphorIconsStyle.regular),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
              ),
            ),

            // Store info
            ListTile(
              // Keep tileColor or other background to transparent
              tileColor: Colors.transparent,
              // contentPadding: const EdgeInsets.all(8),
              leading: _buildCircleAvatar(context, store),
              // Place storeName, phone, address in a white container
              title: Container(
                // padding: const EdgeInsets.all(8),
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

          ],
        ),
      ),
    );
  }
}

Widget _buildCircleAvatar(BuildContext context, Stores store) {
  final imageUrl = store.storeProfileURL;

  return SizedBox(
    width: 50,
    height: 50,
    child: imageUrl == null
        ? CircleAvatar(
      backgroundColor: Colors.red,
      child: Icon(
        PhosphorIcons.storefront(PhosphorIconsStyle.regular),
        color: Colors.white,
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
        backgroundColor: Colors.red,
        child: Icon(
          PhosphorIcons.storefront(PhosphorIconsStyle.regular),
          color: Colors.white,
        ),
      ),
    ),
  );
}

