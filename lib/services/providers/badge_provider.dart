import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/chat.dart';

// 🔢 Named wrapper models
class CartCount {
  final int count;
  CartCount(this.count);
}

class OrderCount {
  final int count;
  OrderCount(this.count);
}

class MessageCount {
  final int count;
  MessageCount(this.count);
}

class NotificationCount{
  final int count;
  NotificationCount(this.count);
}

class StoreMessageCount {
  final int count;
  StoreMessageCount(this.count);
}

class RiderMessageCount {
  final int count;
  RiderMessageCount(this.count);
}

class BadgeProvider {
  static Stream<CartCount> cartItemCountStream() {
    final uid = sharedPreferences!.getString('uid');
    return firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) => CartCount(snapshot.docs.length));
  }

  static Stream<OrderCount> activeOrderCountStream() {
    final uid = sharedPreferences!.getString('uid');
    return firebaseFirestore
        .collection('active_orders')
        .where('userID', isEqualTo: uid)
        .where('orderStatus', whereNotIn: [
      'Cancelled',
      'Delivered',
      'Completing',
      'Completed'
    ])
        .snapshots()
        .map((snapshot) => OrderCount(snapshot.docs.length));
  }

  static Stream<MessageCount> unreadMessagesCountStream() {
    final uid = sharedPreferences!.getString('uid');
    return firebaseFirestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final unread = data['unreadCount'] ?? {};
        if (unread[uid] != null && unread[uid] > 0) {
          count++;
        }
      }
      return MessageCount(count);
    });
  }

  static Stream<NotificationCount> unreadNotificationCountStream() {
    final uid = sharedPreferences!.getString('uid');
    return firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => NotificationCount(snapshot.docs.length));
  }

  static Stream<StoreMessageCount> storeUnreadMessageStream() {
    final uid = sharedPreferences!.getString('uid');
    return firebaseFirestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList();
      final storeChats = chats.where((chat) =>
      chat.partnerRoleFor?[uid] == 'store' &&
          (chat.unreadCount?[uid] ?? 0) > 0);
      return StoreMessageCount(storeChats.length);
    });
  }

  static Stream<RiderMessageCount> riderUnreadMessageStream() {
    final uid = sharedPreferences!.getString('uid');
    return firebaseFirestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList();
      final riderChats = chats.where((chat) =>
      chat.partnerRoleFor?[uid] == 'rider' &&
          (chat.unreadCount?[uid] ?? 0) > 0);
      return RiderMessageCount(riderChats.length);
    });
  }

}
