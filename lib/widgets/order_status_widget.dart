import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Widget orderStatusWidget(String orderStatus) {
  if (orderStatus == 'Pending') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Pending ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Accepted') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "The store accepted your order ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Preparing') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "The store is preparing your order ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Waiting') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Waiting for a rider ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Assigned') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Rider assigned successfully ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Picking up') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Rider is picking your order ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Picked up') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Rider picked up the order ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Delivering') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Rider is on its way! ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Delivered') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Delivered ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Completing') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Completing ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  else if (orderStatus == 'Complete') {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0), // Fully rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wraps tightly around the child
        children: [
          Icon(
            PhosphorIcons.check(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4.0), // Space between icon and text
          const Text(
            "Complete ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  return const SizedBox();
}