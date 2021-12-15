import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Firebase {
  static Future<UploadTask?> uploadFile(XFile file, String courseID) async {
    Reference ref =
        FirebaseStorage.instance.ref().child(courseID).child(file.name);

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
    if (tempFile.existsSync()) tempFile.deleteSync();

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
    if (tempFile.existsSync()) tempFile.deleteSync();
    await fileRef.writeToFile(tempFile);
    return XFile(tempFile.path);
  }

  static Future<List<XFile>> getFiles(String courseID) async {
    ListResult listResult =
        await FirebaseStorage.instance.ref().child(courseID).listAll();

    List<List<dynamic>> filesWithMetadata = [];
    for (var fileRef in listResult.items) {
      filesWithMetadata.add([
        await downloadFileFromReference(fileRef),
        (await fileRef.getMetadata()).timeCreated
      ]);
    }
    filesWithMetadata.sort((a, b) => a[1].compareTo(b[1]));
    List<XFile> files = List<XFile>.generate(
        filesWithMetadata.length, (index) => filesWithMetadata[index][0]);
    return files;
  }

  static Future<ListResult> getFileNames(String courseID) async {
    return await FirebaseStorage.instance.ref().child(courseID).listAll();
  }
}
