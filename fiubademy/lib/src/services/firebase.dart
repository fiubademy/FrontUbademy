import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Firebase {
  static Future<UploadTask?> uploadFile(XFile file) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('playground')
        .child('/some-image.jpg');

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    if (kIsWeb) {
      return Future.value(ref.putData(await file.readAsBytes(), metadata));
    } else {
      return Future.value(ref.putFile(File(file.path), metadata));
    }
  }

  static Future<DownloadTask> downloadFile(String fileName) async {
    final ref = FirebaseStorage.instance.ref(fileName);
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/temp-${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    return Future.value(ref.writeToFile(tempFile));
  }
}
