import 'package:delivery_service_user/mainScreens/main_screen.dart';
import 'package:delivery_service_user/services/providers/badge_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreenProvider extends StatelessWidget {
  const MainScreenProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<CartCount>(
          create: (_) => BadgeProvider.cartItemCountStream(),
          initialData: CartCount(0),
        ),
        StreamProvider<OrderCount>(
          create: (_) => BadgeProvider.activeOrderCountStream(),
          initialData: OrderCount(0),
        ),
        StreamProvider<MessageCount>(
          create: (_) => BadgeProvider.unreadMessagesCountStream(),
          initialData: MessageCount(0),
        ),
        StreamProvider<NotificationCount>(
          create: (_) => BadgeProvider.unreadNotificationCountStream(),
          initialData: NotificationCount(0),
        ),
      ],
      child: const MainScreen(),
    );
  }
}
