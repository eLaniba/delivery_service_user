import 'package:intl/intl.dart';

String orderDateRead(DateTime orderDateTime) {
  String formattedOrderTime = DateFormat('MMMM d, y h:mm a').format(orderDateTime);
  return formattedOrderTime;
}

String capitalizeEachWord(String input) {
  if (input.isEmpty) return input;
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

String formatPhoneNumber(String input) {
  // Trim any surrounding whitespace.
  String trimmed = input.trim();

  // Remove a leading "+63" if it exists.
  if (trimmed.startsWith('+63')) {
    trimmed = trimmed.substring(3);
  }
  // Otherwise, if it starts with a "0", remove that.
  else if (trimmed.startsWith('0')) {
    trimmed = trimmed.substring(1);
  }

  // Return the number with the "+63" prefix appended.
  return '+63$trimmed';
}
