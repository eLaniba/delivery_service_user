import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/notification_screen_2.dart';
import 'package:delivery_service_user/mainScreens/order_screen/order_details_provider.dart';
import 'package:delivery_service_user/mainScreens/order_screen/order_details_provider_screen.dart';
import 'package:delivery_service_user/models/notification_model.dart';
import 'package:delivery_service_user/services/util.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  void notificationRead(BuildContext context, NotificationModel notification) async {
    String uid = sharedPreferences!.getString('uid')!;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NotificationScreen2(
              notification: notification,
              uid: notification.notificationID!)), // Your search screen
    );


    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notification.notificationID)
        .update({'read': true});
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = sharedPreferences!.getString('uid');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications found."));
          }

          final notifications = snapshot.data!.docs.map((doc) {
            final notif = NotificationModel.fromJson(doc.data() as Map<String, dynamic>);
            notif.notificationID = doc.id;
            return notif;
          }).toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final formattedDate = orderDateRead(notification.timestamp!.toDate());

              return Container(
                decoration: BoxDecoration(
                  color: notification.read == false
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                      : Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      PhosphorIcons.package(PhosphorIconsStyle.bold),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    notification.title ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: notification.read == false ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(
                    PhosphorIcons.caretRight(),
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () {
                    notificationRead(context, notification);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
