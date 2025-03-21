import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart'; // Contains sharedPreferences.
import 'package:delivery_service_user/mainScreens/profile_screen/messages_screen_2.dart';
import 'package:delivery_service_user/models/chat.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_service_user/widgets/partner_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current user id from sharedPreferences.
    String currentUserId = sharedPreferences!.getString('uid') ?? '';
    // Determine the partner role based on bottom navigation:
    // Index 0: "store", Index 1: "rider".
    String selectedRole = _selectedIndex == 0 ? 'store' : 'rider';

    // Compute the query stream.
    final Stream<QuerySnapshot> chatStream = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .where('partnerRoleFor.$currentUserId', isEqualTo: selectedRole)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: chatStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      // Convert Firestore data to a Chat model.
                      Chat chat = Chat.fromJson(data);

                      return PartnerListTile(
                        context: context,
                        chat: chat,
                        currentUserId: currentUserId,
                        onTap: () {
                          final partnerId = chat.participants!.firstWhere((id) => id != currentUserId);
                          final partnerName = chat.participantNames?[partnerId] ?? 'Unknown';
                          final partnerImageURL = chat.participantImageURLs?[partnerId] ?? '';
                          final partnerRole = chat.roles?[partnerId] ?? 'user';

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => MessagesScreen2(
                                partnerName: partnerName,
                                partnerID: partnerId,
                                imageURL: partnerImageURL,
                                partnerRole: partnerRole,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? Icon(
              PhosphorIcons.storefront(PhosphorIconsStyle.fill),
              size: 24,
            )
                : Icon(
              PhosphorIcons.storefront(PhosphorIconsStyle.regular),
              size: 24,
            ),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? Icon(
              PhosphorIcons.personSimpleBike(PhosphorIconsStyle.fill),
              size: 24,
            )
                : Icon(
              PhosphorIcons.personSimpleBike(PhosphorIconsStyle.regular),
              size: 24,
            ),
            label: 'Rider',
          ),
        ],
      ),
    );
  }
}
