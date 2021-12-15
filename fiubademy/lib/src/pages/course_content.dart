import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/services/firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

class CourseContentPage extends StatefulWidget {
  final Course course;

  const CourseContentPage({Key? key, required this.course}) : super(key: key);

  @override
  _CourseContentPageState createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  final PageController pageController = PageController();
  late List<Reference> fileNames;
  List<XFile> files = [];
  Map<int, VideoPlayerController> _videoControllers = {};

  Future<void> loadFileNames() async {
    fileNames = await Firebase.getFileNames(widget.course.courseID);
  }

  Future<void> loadFile(int index) async {
    late XFile file;
    if (index < files.length) {
      file = files[index];
    }
    file = await Firebase.downloadFileFromReference(fileNames[index]);
    files.add(file);

    bool isVideo = file.name.split('.')[1] == 'mp4';

    if (isVideo) {
      final _controller = _videoControllers.putIfAbsent(
        index,
        () => VideoPlayerController.file(File(file.path)),
      );
      if (!_controller.value.isInitialized) {
        await _controller.initialize();
      }
    }
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
                    child: PhotoViewGallery.builder(
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      itemCount: fileNames.length,
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

                                  XFile file = files[index];

                                  bool isVideo =
                                      file.name.split('.')[1] == 'mp4';

                                  if (isVideo) {
                                    final _controller =
                                        _videoControllers[index]!;
                                    return PhotoView.customChild(
                                      minScale:
                                          PhotoViewComputedScale.contained *
                                              1.0,
                                      backgroundDecoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      childSize: _controller.value.size,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          VideoPlayer(_controller),
                                          ControlsOverlay(
                                              controller: _controller),
                                          VideoProgressIndicator(_controller,
                                              allowScrubbing: true),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return PhotoView(
                                      minScale:
                                          PhotoViewComputedScale.contained *
                                              1.0,
                                      backgroundDecoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      imageProvider: FileImage(
                                        File(file.path),
                                      ),
                                    );
                                  }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

class ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  const ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  @override
  _ControlsOverlayState createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<ControlsOverlay> {
  static const _playbackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
            });
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: widget.controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              widget.controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _playbackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${widget.controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
