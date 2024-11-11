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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: FirestorePagination(
        query: firebaseFirestore.collection('stores'),
        limit: 20,
        viewType: ViewType.wrap,
        isLive: true,
        itemBuilder: (context, docs, index) {
          Stores stores = Stores.fromJson(docs[index].data() as Map<String, dynamic>,);
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoreCategoryScreen(stores: stores,)));
            },
            child: Container(
              color: Colors.white,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: stores.storeImageURL != null
                      ? Image.network(
                    '${stores.storeImageURL}',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 215, 219, 221),
                        width: 2,
                      ),
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: Color.fromARGB(255, 215, 219, 221),
                    ),
                  ),
                ),
                title: Text(
                  '${stores.storeName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stores.storePhone}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text('${stores.storeAddress}'),
                  ],
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color.fromARGB(255, 215, 219, 221),
                  size: 16,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),
          );
        },
      ),
    );
  }
}
