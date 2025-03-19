import 'dart:io';
import 'dart:typed_data';

import 'package:delivery_service_user/global/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

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

String reformatPhoneNumber(String input) {
  // Trim any surrounding whitespace.
  String trimmed = input.trim();

  // Remove a leading "+63" if it exists.
  if (trimmed.startsWith('+63')) {
    trimmed = trimmed.substring(3);
  }


  // Return the number with the "+63" prefix appended.
  return '0$trimmed';
}

Future<XFile> convertUint8ListToXFile(Uint8List data) async {
  // Get the temporary directory of the app
  final Directory tempDir = await getTemporaryDirectory();

  // Create a unique file path in the temporary directory
  final String filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  // Write the bytes to the file
  final File file = await File(filePath).create();
  await file.writeAsBytes(data);

  // Return an XFile created from the file path
  return XFile(file.path);
}

//Upload an image to Firestore Cloud Storage and return the ImageURL
Future<String> uploadFileAndGetDownloadURL({
  required XFile file,
  required String storagePath,
}) async {
  final ref = firebaseStorage.ref(storagePath);
  final uploadTask = ref.putFile(File(file.path));
  final snapshot = await uploadTask;
  return await snapshot.ref.getDownloadURL();
}
