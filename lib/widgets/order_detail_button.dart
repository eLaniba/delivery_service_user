import 'package:flutter/material.dart';

class OrderDetailButton extends StatelessWidget {
  final String orderStatus;

  const OrderDetailButton({
    Key? key,
    required this.orderStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(orderStatus == 'Pending') {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextButton(
          onPressed: () {

          },
          child: const Text(
            'Accept Order',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          orderStatus,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

