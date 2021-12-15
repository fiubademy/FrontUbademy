import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/services/firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CourseContentPage extends StatefulWidget {
  final Course course;

  const CourseContentPage({Key? key, required this.course}) : super(key: key);

  @override
  _CourseContentPageState createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  final PageController pageController = PageController();
  late ListResult fileNames;
  List<XFile> files = [];

  Future<void> loadFileNames() async {
    fileNames = await Firebase.getFileNames(widget.course.courseID);
  }

  Future<void> loadFile(int index) async {
    if (index < files.length) return;
    files.add(await Firebase.downloadFileFromReference(fileNames.items[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Content'),
      ),
      body: FutureBuilder(
        future: loadFileNames(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return Column(
                children: [
                  Expanded(
                      /*
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: fileNames.items.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: loadFile(index),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              default:
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                if (index == 0) {
                                  return Container(
                                      height: 200,
                                      width: 200,
                                      color: Colors.red);
                                }
                                XFile file = files[index];
                                if (false) {
                                } else {
                                  return PhotoView(imageProvider: kIsWeb
                                        ? Image.network(file.path)
                                        : Image.file(File(file.path)),
                                  );
                                }
                            }
                          },
                        );
                      },
                    ),*/
                      child: PhotoViewGallery.builder(
                          itemCount: fileNames.items.length,
                          builder: (context, index) {
                            return PhotoViewGalleryPageOptions.customChild(
                                child: FutureBuilder(
                              future: loadFile(index),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  default:
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    if (index == 0) {
                                      return Container(
                                          height: 200,
                                          width: 200,
                                          color: Colors.red);
                                    }
                                    XFile file = files[index];
                                    if (false) {
                                    } else {
                                      return PhotoView(
                                          imageProvider:
                                              FileImage(File(file.path)));
                                    }
                                }
                              },
                            ));
                          })),
                ],
              );
          }
        },
      ),
    );
  }
}
