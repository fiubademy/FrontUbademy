import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Firebase {
  static Future<UploadTask?> uploadFile(XFile file, String courseID,
      {String? fileName}) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(courseID)
        .child(fileName ?? file.name);

    if (kIsWeb) {
      return Future.value(ref.putData(await file.readAsBytes()));
    } else {
      return Future.value(ref.putFile(File(file.path)));
    }
  }

  static Future<DownloadTask> downloadFile(String fileName) async {
    final ref = FirebaseStorage.instance.ref(fileName);
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    return Future.value(ref.writeToFile(tempFile));
  }

  static Future<void> deleteFile(XFile file, String courseID) async {
    await FirebaseStorage.instance
        .ref()
        .child(courseID)
        .child(file.name)
        .delete();
  }

  static Future<XFile> downloadFileFromReference(Reference fileRef) async {
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/${fileRef.name}');
    if (tempFile.existsSync()) await tempFile.delete();
    await fileRef.writeToFile(tempFile);
    return XFile(tempFile.path);
  }

  static Future<List<XFile>> getFiles(String courseID) async {
    ListResult listResult =
        await FirebaseStorage.instance.ref().child(courseID).listAll();
    List<XFile> files = [];
    for (var fileRef in listResult.items) {
      files.add(await downloadFileFromReference(fileRef));
    }
    return files;
  }

  static Future<ListResult> getFileNames(String courseID) async {
    return await FirebaseStorage.instance.ref().child(courseID).listAll();
  }
}
