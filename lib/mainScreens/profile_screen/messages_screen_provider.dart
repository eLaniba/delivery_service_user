import 'package:delivery_service_user/mainScreens/profile_screen/messages_screen.dart';
import 'package:delivery_service_user/services/providers/badge_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagesScreenProvider extends StatelessWidget {
  const MessagesScreenProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<StoreMessageCount>(
          create: (_) => BadgeProvider.storeUnreadMessageStream(),
          initialData: StoreMessageCount(0),
        ),
        StreamProvider<RiderMessageCount>(
          create: (_) => BadgeProvider.riderUnreadMessageStream(),
          initialData: RiderMessageCount(0),
        ),
      ],
      child: const MessagesScreen(),
    );
  }
}