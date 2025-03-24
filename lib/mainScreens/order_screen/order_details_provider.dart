import 'package:delivery_service_user/mainScreens/order_screen/order_details_provider_screen.dart';
import 'package:delivery_service_user/services/providers/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_service_user/models/new_order.dart';

class OrderDetailsProvider extends StatelessWidget {
  final String orderId;

  const OrderDetailsProvider({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<NewOrder?>(
      create: (_) => OrderService().streamOrder(orderId),
      initialData: null,
      catchError: (_, __) => null,
      child: const OrderDetailsProviderScreen(),
    );
  }
}
