import 'package:flutter/material.dart';

class CheckoutScreenRemake extends StatefulWidget {
  const CheckoutScreenRemake({super.key});

  @override
  State<CheckoutScreenRemake> createState() => _CheckoutScreenRemakeState();
}

class _CheckoutScreenRemakeState extends State<CheckoutScreenRemake> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [

        ],
      ),
    );
  }
}
