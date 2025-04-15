import 'package:flutter/material.dart';

class TimeLimitDialog extends StatefulWidget {
  const TimeLimitDialog({super.key});

  static Future<int?> show(BuildContext context) async {
    return showDialog<int>(
      context: context,
      builder: (_) => const TimeLimitDialog(),
    );
  }

  @override
  State<TimeLimitDialog> createState() => _TimeLimitDialogState();
}

class _TimeLimitDialogState extends State<TimeLimitDialog> {
  int? selectedTime;

  void _selectTime(int value) {
    setState(() {
      selectedTime = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Time Limit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Set a time limit for adding products. Ensure you complete the process before the timer expires.',
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeOption(1),
              _buildTimeOption(5),
              _buildTimeOption(10),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: selectedTime != null
              ? () {
            Navigator.of(context).pop(selectedTime);
          }
              : null, // disabled if nothing selected
          child: const Text('Start'),
        ),
      ],
    );
  }

  Widget _buildTimeOption(int value) {
    final isSelected = selectedTime == value;

    return GestureDetector(
      onTap: () => _selectTime(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.red.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
