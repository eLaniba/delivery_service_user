import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/new_order.dart';

class OrderService {

  Stream<NewOrder> streamOrder(String orderId) {
    return firebaseFirestore
        .collection('active_orders')
        .doc(orderId)
        .snapshots()
        .map((docSnapshot) {
      if (docSnapshot.exists) {
        return NewOrder.fromJson(docSnapshot.data()!);
      } else {
        throw Exception('Order not found');
      }
    });
  }
}
