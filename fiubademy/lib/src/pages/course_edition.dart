import 'package:flutter/material.dart';
import 'package:material_tag_editor/tag_editor.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/widgets/course_media_picker.dart';

class CourseEditionPage extends StatefulWidget {
  final Course _course;

  const CourseEditionPage({Key? key, required Course course})
      : _course = course,
        super(key: key);

  @override
  _CourseEditionPageState createState() => _CourseEditionPageState();
}

class _CourseEditionPageState extends State<CourseEditionPage> {
  bool isLoading = false;

  void _publish() async {
    setState(() {
      isLoading = true;
    });
    Auth auth = Provider.of<Auth>(context, listen: false);
    Map<String, dynamic> result =
        await Server.publishCourse(auth, widget._course.courseID);
    if (result['error'] != null) {
      final snackBar = SnackBar(content: Text('${result['error']}'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      setState(() {
        widget._course.open = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  List<Widget> _buildCourseState() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'State',
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            widget._course.stateName == 'Open' ? 'Published' : 'In Edition',
            style: Theme.of(context).textTheme.subtitle1,
          )
        ],
      ),
      const SizedBox(height: 16.0),
      if (widget._course.stateName != 'Open')
        SizedBox(
          width: double.maxFinite,
          child: ElevatedButton(
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                    title: const Text('Publish Course'),
                    content: Text(
                        'Once published, you won\'t be able to edit the course anymore.\n\nAre you sure you want to publish ${widget._course.title}?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('CANCEL'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _publish();
                          Navigator.pop(context);
                        },
                        child: const Text('PUBLISH'),
                      ),
                    ]),
              );
            },
            style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondaryVariant),
            child: const Text('PUBLISH'),
          ),
        ),
    ];
  }

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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('General Information',
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  const SizedBox(height: 16.0),
                  CourseEditionForm(course: widget._course),
                  const SizedBox(height: 8.0),
                  const Divider(),
                  const SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Multimedia Content',
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  const SizedBox(height: 16.0),
                  CourseMultimediaPicker(course: widget._course),
                  const SizedBox(height: 8.0),
                  const Divider(),
                  const SizedBox(height: 8.0),
                  ..._buildCourseState(),
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

  @override
  void initState() {
    _tags = widget._course.tags;
    super.initState();
  }

  void _edit() async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Auth auth = Provider.of<Auth>(context, listen: false);
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
      String? result = await Server.updateCourse(
        auth,
        courseID: widget._course.courseID,
        name: _courseTitle!,
        description: _courseDescription!,
        category: _courseCategory!,
        hashtags: _tags,
        minSubscription: minSubLevel,
      );
      if (result == null) {
        SnackBar snackBar =
            const SnackBar(content: Text('Successfully updated course'));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = SnackBar(content: Text(result));
        if (!mounted) return;
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
            enabled: widget._course.stateName != 'Open',
            readOnly: widget._course.stateName != 'Open',
            initialValue: widget._course.title,
            validator: (value) => _validateTitle(value),
            onSaved: (value) => _courseTitle = value,
            decoration: InputDecoration(
                enabled: widget._course.stateName != 'Open',
                hintText: 'My Brand New Course',
                labelText: 'Title*',
                border: const OutlineInputBorder(),
                helperText: '*Required'),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            enabled: widget._course.stateName != 'Open',
            initialValue: widget._course.description,
            validator: (value) => _validateDescription(value),
            onSaved: (value) => _courseDescription = value,
            decoration: InputDecoration(
              enabled: widget._course.stateName != 'Open',
              hintText: 'A detailed description about your course',
              labelText: 'Description*',
              hintMaxLines: 2,
              border: const OutlineInputBorder(),
            ),
            maxLines: null,
          ),
          const SizedBox(height: 16.0),
          MaterialDropdownButton(
            enabled: widget._course.stateName != 'Open',
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
            enabled: widget._course.stateName != 'Open',
            options: const <String>['Free', 'Standard', 'Premium'],
            initialValue: widget._course.minSubscriptionName,
            onSaved: (value) => _courseMinSubscriptionLevel = value,
          ),
          const SizedBox(height: 16.0),
          TagEditor(
            enabled: widget._course.stateName != 'Open',
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
              onDeleted: widget._course.stateName == 'Open'
                  ? null
                  : () {
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
                    onPressed: widget._course.stateName == 'Open'
                        ? null
                        : () => _edit(),
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
  final enabled;

  MaterialDropdownButton({
    Key? key,
    required this.options,
    this.hint,
    this.defaultOption,
    this.enabled = true,
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
                enabled: enabled,
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
                  onChanged: enabled
                      ? (String? newValue) {
                          if (newValue != state.value) {
                            state.didChange(newValue);
                          }
                        }
                      : null,
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
