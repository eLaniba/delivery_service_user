import 'package:delivery_service_user/mainScreens/store_screen/store_item_screen.dart';
import 'package:delivery_service_user/models/category_item.dart';
import 'package:delivery_service_user/models/stores.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategoryCard extends StatelessWidget {
  final Stores store;
  final Category category;

  const CategoryCard({Key? key, required this.category, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => StoreItemScreen(store: store, categoryModel: category,),
          ),
        );
      },
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: category.categoryImageURL != null
                  ? CachedNetworkImage(
                imageUrl: category.categoryImageURL!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(
                        PhosphorIcons.image(PhosphorIconsStyle.fill),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                const Icon(Icons.error),
              )
                  : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 215, 219, 221),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: Color.fromARGB(255, 215, 219, 221),
                ),
              ),
            ),
            tileColor: Colors.white,
            title: Text('${category.categoryName}'),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color.fromARGB(255, 215, 219, 221),
              size: 16,
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          const Divider(
            color: Color.fromARGB(255, 242, 243, 244),
            height: 1,
            thickness: 1,
            indent: 72,
            endIndent: 16,
          ),
        ],
      ),
    );
  }
}
