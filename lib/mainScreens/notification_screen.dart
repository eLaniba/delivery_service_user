import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/notification_screen_2.dart';
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
        .collection('stores')
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
                color: notification.read == false ? Colors.blue.withOpacity(0.1) : null,
                child: ListTile(
                  leading: Icon(
                    PhosphorIcons.package(PhosphorIconsStyle.bold),
                    size: 32,
                  ),
                  title: Text(notification.title ?? ''),
                  subtitle: Text(formattedDate),
                  trailing: Icon(PhosphorIcons.caretRight()),
                  onTap: () {
                    // Add your onTap logic here
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
