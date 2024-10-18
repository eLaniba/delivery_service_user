import 'package:delivery_service_user/mainScreens/store_category_screen.dart';
import 'package:delivery_service_user/models/sellers.dart';
import 'package:flutter/material.dart';

class SellerInfo extends StatefulWidget {
  Sellers? model;
  BuildContext? context;

  SellerInfo({this.model, this.context});

  @override
  _SellerInfoState createState() => _SellerInfoState();
}

class _SellerInfoState extends State<SellerInfo> {
  @override
  Widget build(BuildContext context) {
    return Card(
      // elevation: 4,
      // margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoreCategoryScreen(model: widget.model,)));
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                // width: 100,
                height: 100,
                child: Placeholder(),
              ),
              const SizedBox(height: 4),
              //Store Icon & Icon Store
              Row(
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 16,
                  ),
                  Expanded(child: Text(widget.model!.sellerName!)),
                ],
              ),
              //Location Icon & Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.black87,
                    size: 12,
                  ),
                  Expanded(
                    child: Text(
                      widget.model!.sellerAddress!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: AlignmentDirectional.topStart,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.model!.sellerPhone!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
