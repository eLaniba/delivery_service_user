import 'package:delivery_service_user/models/sellers.dart';
import 'package:flutter/material.dart';

class InfoDesignWidget extends StatefulWidget {
  Sellers? model;
  BuildContext? context;

  InfoDesignWidget({this.model, this.context});

  @override
  _InfoDesignWidgetState createState() => _InfoDesignWidgetState();
}

// class _InfoDesignWidgetState extends State<InfoDesignWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       splashColor: Colors.amber,
//       child: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Container(
//           height: 100,
//           width: MediaQuery.of(context).size.width,
//           child: Column(
//             children: [
//               Icon(Icons.store),
//               const SizedBox(height: 1.0,),
//               Text(
//                 widget.model!.sellerName!,
//                 style: const TextStyle(
//                   color: Colors.cyan,
//                   fontSize: 20,
//                   fontFamily: "Train",
//                 ),
//               ),
//               Text(
//                 widget.model!.sellerEmail!,
//                 style: const TextStyle(
//                   color: Colors.grey,
//                   fontSize: 12,
//                 ),
//               ),
//               Divider(
//                 height: 4,
//                 thickness: 3,
//                 color: Colors.grey[300],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
class _InfoDesignWidgetState extends State<InfoDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      // elevation: 4,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {},
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
