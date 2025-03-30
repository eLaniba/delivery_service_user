import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/models/new_order.dart';
import 'package:delivery_service_user/widgets/show_floating_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateScreen extends StatefulWidget {
  final NewOrder order;

  @override
  _RateScreenState createState() => _RateScreenState();

  RateScreen({super.key, required this.order});
}

class _RateScreenState extends State<RateScreen> {
  double storeRating = 0;
  double riderRating = 0;

  void submitRatings() async {
    if (storeRating == 0 || riderRating == 0) {
      showFloatingToast(
        context: context,
        message: 'Please rate the store and rider.',
        backgroundColor: Colors.red,
      );
      return;
    }

    showFloatingToast(
      context: context,
      message: 'Submitting rate...',
    );

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Firestore references
      DocumentReference storeRef = firestore.collection('stores').doc(widget.order.storeID);
      DocumentReference riderRef = firestore.collection('riders').doc(widget.order.riderID);
      DocumentReference orderRef = firestore.collection('active_orders').doc(widget.order.orderID);

      // Firestore transaction to ensure atomic updates
      await firestore.runTransaction((transaction) async {
        // Read both documents first (Firestore requires all reads before writes)
        DocumentSnapshot storeSnapshot = await transaction.get(storeRef);
        DocumentSnapshot riderSnapshot = await transaction.get(riderRef);

        // Extract store data
        Map<String, dynamic> storeData = storeSnapshot.data() as Map<String, dynamic>? ?? {};
        double storeTotalRate = (storeData['totalRate'] ?? 0) + storeRating;
        int storeNumRate = (storeData['numRate'] ?? 0) + 1;
        double storeAverageRate = storeTotalRate / storeNumRate;

        // Extract rider data
        Map<String, dynamic> riderData = riderSnapshot.data() as Map<String, dynamic>? ?? {};
        double riderTotalRate = (riderData['totalRate'] ?? 0) + riderRating;
        int riderNumRate = (riderData['numRate'] ?? 0) + 1;
        double riderAverageRate = riderTotalRate / riderNumRate;

        // Update Store Ratings
        transaction.set(storeRef, {
          'totalRate': storeTotalRate,
          'numRate': storeNumRate,
          'averageRate': storeAverageRate,
        }, SetOptions(merge: true));

        // Update Rider Ratings
        transaction.set(riderRef, {
          'totalRate': riderTotalRate,
          'numRate': riderNumRate,
          'averageRate': riderAverageRate,
        }, SetOptions(merge: true));

        // Update order to mark as rated
        transaction.update(orderRef, {'rate': true});
      });

      showFloatingToast(
        context: context,
        message: 'Ratings submitted successfully!',
        backgroundColor: Colors.green,
      );

      Navigator.of(context).pop();
    } catch (e) {
      showFloatingToast(
        context: context,
        message: 'Error submitting ratings. Try again.',
        backgroundColor: Colors.red,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Store & Rider'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Rate the Store', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: storeRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    storeRating = rating;
                  });
                },
              ),
              const SizedBox(height: 30),
              const Text('Rate the Rider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: riderRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    riderRating = rating;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextButton(
            onPressed: submitRatings,
            child: const Text(
              'Submit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

      ),
    );
  }
}
