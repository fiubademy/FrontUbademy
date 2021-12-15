import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/services/firebase.dart';

class CourseMultimediaPicker extends StatefulWidget {
  final Course course;
  const CourseMultimediaPicker({Key? key, required this.course})
      : super(key: key);

  @override
  _CourseMultimediaPickerState createState() => _CourseMultimediaPickerState();
}

class _CourseMultimediaPickerState extends State<CourseMultimediaPicker> {
  List<XFile> _fileList = [];
  List<XFile> _deletedFileList = [];
  List<XFile> _newFileList = [];

  Future<void> getFiles() async {
    _fileList = await Firebase.getFiles(widget.course.courseID);
  }

  void _deleteFile(XFile deletedFile) {
    if (!_fileList.contains(deletedFile)) return;

    _fileList.removeWhere((item) => item == deletedFile);
    _deletedFileList.add(deletedFile);
  }

  void _addFile(XFile newFile) {
    _newFileList.add(newFile);
  }

  void _saveFiles() async {
    try {
      for (var file in _newFileList) {
        await Firebase.uploadFile(file, widget.course.courseID);
      }
      for (var file in _deletedFileList) {
        await Firebase.deleteFile(file, widget.course.courseID);
      }
    } on FirebaseException catch (error) {
      final snackBar = SnackBar(content: Text('$error'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getFiles(),
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
              return MultimediaPicker(
                course: widget.course,
                initialFiles: _fileList,
                onDelete: _deleteFile,
                onAdd: _addFile,
                onSave: _saveFiles,
              );
          }
        });
  }
}

class MultimediaPicker extends StatefulWidget {
  final Course course;
  final List<XFile>? initialFiles;
  final void Function()? onSave;
  final void Function(XFile file)? onAdd;
  final void Function(XFile file)? onDelete;

  const MultimediaPicker(
      {Key? key,
      required this.course,
      this.initialFiles,
      this.onSave,
      this.onAdd,
      this.onDelete})
      : super(key: key);

  @override
  _MultimediaPickerState createState() => _MultimediaPickerState();
}

class _MultimediaPickerState extends State<MultimediaPicker> {
  // List<dynamic> has (file, type), 0 for image, 1 for video
  final List<List<dynamic>> _fileList = [];

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialFiles != null) {
      // Add all images as unmodifiable lists [file, 0].
      _fileList.addAll(List.generate(widget.initialFiles!.length, (index) {
        XFile file = widget.initialFiles![index];
        int indexOfExtension = file.name.lastIndexOf('.') + 1;
        if (file.name.substring(indexOfExtension) == 'mp4') {
          return List.unmodifiable([widget.initialFiles![index], 1]);
        } else {
          return List.unmodifiable([widget.initialFiles![index], 0]);
        }
      }));
    }
  }

  void _onVideoButtonPressed(ImageSource source) async {
    try {
      final XFile? videoFile = await _picker.pickVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      if (videoFile != null) {
        setState(() {
          _fileList.add(List.unmodifiable([videoFile, 1]));
          widget.onAdd?.call(videoFile);
        });
      }
    } catch (error) {
      final snackBar = SnackBar(content: Text('$error'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _onMultiImageButtonPressed() async {
    try {
      final pickedFileList = await _picker.pickMultiImage();
      if (pickedFileList != null) {
        setState(() {
          // Add all images as unmodifiable lists [file, 0].
          _fileList.addAll(List.generate(pickedFileList.length,
              (index) => List.unmodifiable([pickedFileList[index], 0])));
          for (final file in pickedFileList) {
            widget.onAdd?.call(file);
          }
        });
      }
    } catch (error) {
      final snackBar = SnackBar(content: Text('$error'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _onCameraButtonPressed() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        setState(() {
          _fileList.add(List.unmodifiable([pickedFile, 0]));
          widget.onAdd?.call(pickedFile);
        });
      }
    } catch (error) {
      final snackBar = SnackBar(content: Text('$error'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Widget _buildFileWidget(int index) {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }

    if (_fileList[index][1] == 1) {
      // Video
      return AspectRatioVideo(
        videoFile: _fileList[index][0],
        onDelete: widget.course.stateName == 'Open'
            ? null
            : (XFile file) {
                setState(() {
                  _fileList.removeWhere((item) => item[0] == file);
                  widget.onDelete?.call(file);
                });
              },
      );
    } else {
      return AspectRatioImage(
        imageFile: _fileList[index][0],
        onDelete: widget.course.stateName == 'Open'
            ? null
            : (XFile file) {
                setState(() {
                  _fileList.removeWhere((item) => item[0] == file);
                  widget.onDelete?.call(file);
                });
              },
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();

    if (response.isEmpty) {
      return;
    }

    if (response.file == null) {
      _retrieveDataError = response.exception!.code;
    }

    if (response.type == RetrieveType.video) {
      setState(() {
        _fileList.add(List.unmodifiable([response.file!, 1]));
        widget.onAdd?.call(response.file!);
      });
    } else {
      setState(() {
        // Add All elements as unmodifiable lists [file, 0]
        if (response.files != null) {
          _fileList.addAll(List.generate(response.files!.length,
              (index) => List.unmodifiable([response.files!, 0])));
          for (final file in response.files!) {
            widget.onAdd?.call(file);
          }
        } else {
          _fileList.add(List.unmodifiable([response.file!, 0]));
          widget.onAdd?.call(response.file!);
        }
      });
    }
  }

  Widget _buildFileGrid() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overscroll) {
        overscroll.disallowGlow();
        return false;
      },
      child: GridView.builder(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          crossAxisCount: 2,
        ),
        itemCount: _fileList.length + 1,
        itemBuilder: (context, index) {
          if (index == _fileList.length) {
            return InkWell(
              onTap: () {
                _displayImageTypeDialog();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraint) {
                      return Icon(Icons.add_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: constraint.biggest.height * 0.4);
                    },
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondaryVariant,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withAlpha(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildFileWidget(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        kIsWeb || defaultTargetPlatform != TargetPlatform.android
            ? _buildFileGrid()
            : FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(child: CircularProgressIndicator());
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      }

                      return _buildFileGrid();
                  }
                },
              ),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: widget.course.stateName == 'Open'
                ? null
                : () {
                    widget.onSave?.call();
                  },
            child: const Text('SAVE'),
          ),
        ),
      ],
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  void _displayImageTypeDialog() async {
    int? result = await showGeneralDialog(
        context: context,
        barrierLabel: "Label",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 700),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        },
        pageBuilder: (context, anim1, anim2) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: IntrinsicHeight(
              child: Container(
                width: double.maxFinite,
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                margin: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Material(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, 0);
                            },
                            child: const Icon(Icons.photo_library_rounded),
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Gallery',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, 1);
                            },
                            child: const Icon(Icons.video_library_rounded),
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Video',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, 2);
                            },
                            child: const Icon(Icons.camera_alt_rounded),
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Camera',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, 3);
                            },
                            child: const Icon(Icons.video_camera_back_rounded),
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text('Record'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });

    if (result == null) return;
    switch (result) {
      case 0:
        _onMultiImageButtonPressed();
        break;
      case 1:
        _onVideoButtonPressed(ImageSource.gallery);
        break;
      case 2:
        _onCameraButtonPressed();
        break;
      case 3:
        _onVideoButtonPressed(ImageSource.camera);
        break;
    }
  }
}

class AspectRatioImage extends StatelessWidget {
  final XFile imageFile;
  final void Function(XFile file)? onDelete;

  const AspectRatioImage({Key? key, required this.imageFile, this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Center(
              // Image
              // Why network for web?
              // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
              child: kIsWeb
                  ? Image.network(imageFile.path)
                  : Image.file(File(imageFile.path)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.maxFinite,
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                color: Colors.black54,
              ),
              child: Text(
                '${imageFile.name.split('.')[1]} Image',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
          if (onDelete != null)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => onDelete?.call(imageFile),
                icon: const Icon(Icons.delete_rounded, color: Colors.black54),
              ),
            ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondaryVariant,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.withOpacity(0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

class AspectRatioVideo extends StatefulWidget {
  final XFile _videoFile;
  final void Function(XFile file)? onDelete;

  const AspectRatioVideo({Key? key, required XFile videoFile, this.onDelete})
      : _videoFile = videoFile,
        super(key: key);

  @override
  _AspectRatioVideoState createState() => _AspectRatioVideoState();
}

class _AspectRatioVideoState extends State<AspectRatioVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget._videoFile.path))
      ..initialize().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.maxFinite,
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                color: Colors.black54,
              ),
              child: Text(
                '${widget._videoFile.name.split('.')[1]} Video',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (widget.onDelete != null)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => widget.onDelete?.call(widget._videoFile),
                icon: const Icon(Icons.delete_rounded, color: Colors.black54),
              ),
            ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondaryVariant,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.withOpacity(0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
