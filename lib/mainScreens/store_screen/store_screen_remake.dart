import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_category_screen.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/widgets/progress_bar.dart';
import 'package:delivery_service_user/widgets/seller_info.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class StoreScreenRemake extends StatefulWidget {
  const StoreScreenRemake({super.key});

  @override
  State<StoreScreenRemake> createState() => _StoreScreenRemakeState();
}

class _StoreScreenRemakeState extends State<StoreScreenRemake> {
  @override
  Widget build(BuildContext context) {
    return FirestorePagination(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      query: firebaseFirestore.collection('stores'),
      limit: 10,
      viewType: ViewType.wrap,
      isLive: true,
      itemBuilder: (context, docs, index) {
        Stores stores = Stores.fromJson(docs[index].data() as Map<String, dynamic>,);
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoreCategoryScreen(stores: stores,)));
          },
          child: Container(
            // padding: EdgeInsets.all(8.0),
            // margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            // child: ListTile(
            //   leading: ClipRRect(
            //     borderRadius: BorderRadius.circular(8),
            //     child: stores.storeImageURL != null
            //         ? CachedNetworkImage(
            //           imageUrl: '${stores.storeImageURL}',
            //           width: 48,
            //           height: 48,
            //           fit: BoxFit.cover,
            //           fadeInDuration: Duration.zero,
            //           fadeOutDuration: Duration.zero,
            //           placeholder: (context, url) =>
            //               Shimmer.fromColors(
            //                 baseColor: Colors.grey[300]!,
            //                 highlightColor: Colors.grey[100]!,
            //                 child: SizedBox(
            //                   width: 48,
            //                   height: 48,
            //                   // color: Colors.white,
            //                   child: Center(
            //                     child: Icon(
            //                       PhosphorIcons.image(
            //                           PhosphorIconsStyle.fill),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //           // Placeholder while image is loading
            //           errorWidget: (context, url, error) =>
            //               Icon(Icons.error),
            //     )
            //         : Container(
            //       width: 60,
            //       height: 60,
            //       decoration: BoxDecoration(
            //         border: Border.all(
            //           color: const Color.fromARGB(255, 215, 219, 221),
            //           width: 2,
            //         ),
            //         borderRadius:
            //         BorderRadius.circular(8),
            //       ),
            //       child: const Icon(
            //         Icons.image_outlined,
            //         color: Color.fromARGB(255, 215, 219, 221),
            //       ),
            //     ),
            //   ),
            //   title: Row(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Icon(PhosphorIcons.storefront(PhosphorIconsStyle.regular)),
            //       Flexible(
            //         child: Text(
            //           '${stores.storeName} Premium by Park N Go Calape Branch',
            //           style: const TextStyle(
            //             fontWeight: FontWeight.bold,
            //           ),
            //           maxLines: 1,
            //           overflow: TextOverflow.ellipsis,
            //         ),
            //       ),
            //     ],
            //   ),
            //   subtitle: Column(
            //     mainAxisSize: MainAxisSize.min,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         '${stores.storePhone}',
            //         style: const TextStyle(
            //           color: Colors.grey,
            //         ),
            //       ),
            //       Text('${stores.storeAddress}'),
            //     ],
            //   ),
            //   trailing: const Icon(
            //     Icons.arrow_forward_ios_rounded,
            //     color: Color.fromARGB(255, 215, 219, 221),
            //     size: 16,
            //   ),
            //   contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Network image
              SizedBox(
              height: 150,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: stores.storeImageURL != null
                    ? CachedNetworkImage(
                  imageUrl: '${stores.storeImageURL}',
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
              ),
            ),
            const SizedBox(height: 8,),
                //Store Info
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Store Icon + Name
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIcons.storefront(PhosphorIconsStyle.regular),
                            ),
                            Flexible(
                              child: Text(
                                '${stores.storeName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          ],
                        ),
                      ),
                      //Store Phone Number
                      Text(
                        '${stores.storePhone}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Text('${stores.storeAddress}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
