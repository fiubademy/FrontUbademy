import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_tag_editor/tag_editor.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/services/user.dart';

class CourseEditionPage extends StatelessWidget {
  final Course _course;

  const CourseEditionPage({Key? key, required Course course})
      : _course = course,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Course')),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
              child: Column(
                children: [
                  CourseEditionForm(course: _course),
                  MultimediaPicker(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CourseEditionForm extends StatefulWidget {
  final Course _course;

  const CourseEditionForm({Key? key, required Course course})
      : _course = course,
        super(key: key);

  @override
  _CourseEditionFormState createState() => _CourseEditionFormState();
}

class _CourseEditionFormState extends State<CourseEditionForm> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? _courseTitle;
  String? _courseDescription;
  String? _courseCategory;
  String? _courseMinSubscriptionLevel;
  List<String> _tags = [];
  List<XFile> _files = [];

  @override
  void initState() {
    _tags = widget._course.tags;
    super.initState();
  }

  void _create() async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Auth auth = Provider.of<Auth>(context, listen: false);
      User user = Provider.of<User>(context, listen: false);
      int minSubLevel;
      switch (_courseMinSubscriptionLevel) {
        case 'Standard':
          minSubLevel = 1;
          break;
        case 'Premium':
          minSubLevel = 2;
          break;
        default:
          minSubLevel = 0;
      }
      String? result = await Server.createCourse(
        auth,
        _courseTitle!,
        _courseDescription!,
        _courseCategory!,
        _tags,
        minSubLevel,
        user.latitude!,
        user.longitude!,
      );
      if (result == null) {
        Navigator.pop(context);
      } else {
        final snackBar = SnackBar(content: Text(result));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: widget._course.title,
            validator: (value) => _validateTitle(value),
            onSaved: (value) => _courseTitle = value,
            decoration: const InputDecoration(
                hintText: 'My Brand New Course',
                labelText: 'Title*',
                border: OutlineInputBorder(),
                helperText: '*Required'),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            initialValue: widget._course.description,
            validator: (value) => _validateDescription(value),
            onSaved: (value) => _courseDescription = value,
            decoration: const InputDecoration(
              hintText: 'A detailed description about your course',
              labelText: 'Description*',
              hintMaxLines: 2,
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
          const SizedBox(height: 16.0),
          MaterialDropdownButton(
            options: Course.categories(),
            initialValue: widget._course.category,
            hint: 'Category',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a course category';
              }
            },
            onSaved: (value) => _courseCategory = value,
          ),
          const SizedBox(height: 16.0),
          MaterialDropdownButton(
            options: const <String>['Free', 'Standard', 'Premium'],
            initialValue: widget._course.minSubscriptionName,
            onSaved: (value) => _courseMinSubscriptionLevel = value,
          ),
          const SizedBox(height: 16.0),
          TagEditor(
            length: _tags.length,
            delimiters: const [',', ' '],
            hasAddButton: true,
            inputDecoration: const InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 0, 0),
              border: InputBorder.none,
              hintText: 'Tags...',
            ),
            onTagChanged: (newValue) {
              setState(() {
                _tags.add(newValue);
              });
            },
            tagBuilder: (context, index) => Chip(
              label: Text(_tags[index],
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              onDeleted: () {
                setState(() {
                  _tags.removeWhere((element) => element == _tags[index]);
                });
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _create(),
                    child: const Text('SAVE'),
                  ),
          ),
        ],
      ),
    );
  }
}

// TODO Move to widget folder
class MaterialDropdownButton extends FormField<String> {
  final List<String> options;
  final String? hint;
  final String? defaultOption;

  MaterialDropdownButton({
    Key? key,
    required this.options,
    this.hint,
    this.defaultOption,
    String? initialValue,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          autovalidateMode: AutovalidateMode.disabled,
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              decoration: InputDecoration(
                errorText: state.errorText,
                hintText: hint,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              isEmpty: state.value == null,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: state.value,
                  isDense: true,
                  onChanged: (String? newValue) {
                    if (newValue != state.value) {
                      state.didChange(newValue);
                    }
                  },
                  items: options.map(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    },
                  ).toList(),
                ),
              ),
            );
          },
        );
}

class MultimediaPicker extends StatefulWidget {
  const MultimediaPicker({Key? key}) : super(key: key);

  @override
  _MultimediaPickerState createState() => _MultimediaPickerState();
}

class _MultimediaPickerState extends State<MultimediaPicker> {
  final List<List<dynamic>> _imageFileList = [];

  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  void _onVideoButtonPressed(ImageSource source) async {
    try {
      final XFile? videoFile = await _picker.pickVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      if (videoFile != null) {
        setState(() {
          _imageFileList.add(List.unmodifiable([videoFile, 1]));
        });
      }
    } catch (error) {
      final snackBar = SnackBar(content: Text('$error'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _onMultiImageButtonPressed() async {
    try {
      final pickedFileList = await _picker.pickMultiImage();
      if (pickedFileList != null) {
        setState(() {
          // Add all images as unmodifiable lists [file, 0].
          _imageFileList.addAll(List.generate(pickedFileList.length,
              (index) => List.unmodifiable([pickedFileList[index], 0])));
        });
      }
    } catch (error) {
      final snackBar = SnackBar(content: Text('$error'));
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
          _imageFileList.add(List.unmodifiable([pickedFile, 0]));
        });
      }
    } catch (error) {
      final snackBar = SnackBar(content: Text('$error'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Widget _previewVideo() {
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Widget _previewImages(int index) {
    // Why network for web?
    // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
    return kIsWeb
        ? Image.network(_imageFileList[index][0].path)
        : Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Image.file(
                  File(_imageFileList[index][0].path),
                ),
              ),
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

  Widget _handlePreview(int index) {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }

    if (_imageFileList[index][1] == 1) {
      return Text('Video');
    } else {
      return _previewImages(index);
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
        _imageFileList.add(List.unmodifiable([response.file!, 1]));
      });
    } else {
      setState(() {
        // Add All elements as unmodifiable lists [file, 0]
        if (response.files != null) {
          _imageFileList.addAll(List.generate(response.files!.length,
              (index) => List.unmodifiable([response.files!, 0])));
        } else {
          _imageFileList.add(List.unmodifiable([response.file!, 0]));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscaffold'),
      ),
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return //_handlePreview();
                          GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          crossAxisCount: 2,
                        ),
                        padding: const EdgeInsets.all(16),
                        itemCount: _imageFileList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _imageFileList.length) {
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size:
                                              constraint.biggest.height * 0.4);
                                    },
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryVariant,
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
                          return _handlePreview(index);
                        },
                      );
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : _handlePreview(0),
      ),
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

  @override
  void deactivate() {
    if (_controller != null) {
      _controller!.setVolume(0.0);
      _controller!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}
