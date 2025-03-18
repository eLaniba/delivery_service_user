// partner_list_tile.dart

import 'package:delivery_service_user/global/global.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:delivery_service_user/models/chat.dart';

class PartnerListTile extends StatelessWidget {
  final BuildContext context;
  final Chat chat;
  final String currentUserId;
  final VoidCallback? onTap;

  const PartnerListTile({
    Key? key,
    required this.context,
    required this.chat,
    required this.currentUserId,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the partner's id (the one that is not the current user)
    final partnerId = chat.participants!.firstWhere((id) => id != currentUserId);
    final partnerName = chat.participantNames?[partnerId] ?? 'Unknown';
    final lastMessage = chat.lastMessage ?? '';
    final unreadCount = chat.unreadCount?[currentUserId] ?? 0;
    final partnerImageURL = chat.participantImageURLs?[partnerId] ?? '';

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey,
        child: partnerImageURL.isNotEmpty
            ? ClipOval(
          child: CachedNetworkImage(
            imageUrl: partnerImageURL,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        )
            : const Icon(Icons.person),
      ),
      title: Text(
        partnerName,
        style: TextStyle(
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        lastMessage,
        style: TextStyle(
          color: unreadCount > 0 ? Colors.black : gray,
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: unreadCount > 0 ? Colors.red : gray.withOpacity(.5),
        ),
      ),
      onTap: onTap,
    );
  }
}
