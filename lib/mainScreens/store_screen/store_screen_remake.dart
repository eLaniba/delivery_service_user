import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/store_screen/store_category_screen.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:delivery_service_user/widgets/store_card.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';


class StoreScreenRemake extends StatefulWidget {
  const StoreScreenRemake({super.key});

  @override
  State<StoreScreenRemake> createState() => _StoreScreenRemakeState();
}

class _StoreScreenRemakeState extends State<StoreScreenRemake> {
  @override
  Widget build(BuildContext context) {
    return FirestorePagination(
      // padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      query: firebaseFirestore.collection('stores').where('status', isEqualTo: 'registered'),
      limit: 10,
      viewType: ViewType.wrap,
      isLive: true,
      itemBuilder: (context, docs, index) {
        Stores stores = Stores.fromJson(docs[index].data() as Map<String, dynamic>,);
        // return InkWell(
        //   onTap: () {
        //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoreCategoryScreen(stores: stores,)));
        //   },
        //   child: Card(
        //     elevation: 4,
        //     child: Container(
        //       // padding: EdgeInsets.all(8.0),
        //       // margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        //       margin: const EdgeInsets.only(bottom: 4),
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(8),
        //         color: Colors.white,
        //       ),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           // Network image
        //         SizedBox(
        //         height: 150,
        //         width: double.infinity,
        //         child: ClipRRect(
        //               borderRadius: const BorderRadius.only(
        //                 topLeft: Radius.circular(8),
        //                 topRight: Radius.circular(8),
        //               ),
        //               child: stores.storeImageURL != null
        //                   ? CachedNetworkImage(
        //                       imageUrl: '${stores.storeImageURL}',
        //                       fit: BoxFit.cover,
        //                       placeholder: (context, url) => Shimmer.fromColors(
        //                         baseColor: Colors.grey[300]!,
        //                         highlightColor: Colors.grey[100]!,
        //                         child: SizedBox(
        //                           height: 200,
        //                           child: Center(
        //                             child: Icon(
        //                               PhosphorIcons.image(
        //                                   PhosphorIconsStyle.fill),
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                       errorWidget: (context, url, error) => Container(
        //                         color: white80,
        //                         child: Icon(
        //                           PhosphorIcons.imageBroken(
        //                               PhosphorIconsStyle.fill),
        //                           color: Colors.white,
        //                           size: 48,
        //                         ),
        //                       ),
        //                     )
        //                   : Container(
        //                       color: white80,
        //                       child: Icon(
        //                         PhosphorIcons.imageBroken(
        //                             PhosphorIconsStyle.fill),
        //                         color: Colors.white,
        //                       ),
        //                     ),
        //             ),
        //       ),
        //           //Store Info
        //           Padding(
        //             padding: const EdgeInsets.all(16),
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 //Store Icon + Name
        //                 SizedBox(
        //                   width: double.infinity,
        //                   child: Row(
        //                     crossAxisAlignment: CrossAxisAlignment.center,
        //                     children: [
        //                       Icon(
        //                         PhosphorIcons.storefront(PhosphorIconsStyle.regular),
        //                       ),
        //                       Flexible(
        //                         child: Text(
        //                           '${stores.storeName}',
        //                           style: const TextStyle(
        //                             fontSize: 18,
        //                             fontWeight: FontWeight.bold,
        //                           ),
        //                           maxLines: 1,
        //                           overflow: TextOverflow.ellipsis,
        //                         ),
        //                       ),
        //
        //                     ],
        //                   ),
        //                 ),
        //                 //Store Phone Number
        //                 Text(
        //                   reformatPhoneNumber(stores.storePhone!),
        //                   style: const TextStyle(
        //                     color: Colors.grey,
        //                   ),
        //                 ),
        //                 Text('${stores.storeAddress}'),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // );
        return StoreCard(
          store: stores,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoreCategoryScreen(stores: stores,),),);
          },
        );
      },
    );
  }
}
