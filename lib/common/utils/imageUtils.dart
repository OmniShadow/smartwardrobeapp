import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static Future<XFile?> captureImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      return pickedFile;
    } else {
      return null;
    }
  }

  static Future<String> imageToBase64(XFile imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64String = base64Encode(imageBytes);
    return base64String;
  }
}
