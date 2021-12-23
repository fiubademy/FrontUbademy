import 'package:flutter/material.dart';
import 'package:material_tag_editor/tag_editor.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/models/course.dart';

import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:fiubademy/src/services/server.dart';

class CreateCoursePage extends StatelessWidget {
  const CreateCoursePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Course'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Column(
            children: const [
              CourseCreateForm(),
            ],
          ),
        ),
      ),
    );
  }
}

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

class CourseCreateForm extends StatefulWidget {
  const CourseCreateForm({Key? key}) : super(key: key);

  @override
  _CourseCreateFormState createState() => _CourseCreateFormState();
}

class _CourseCreateFormState extends State<CourseCreateForm> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? _courseTitle;
  String? _courseDescription;
  String? _courseCategory;
  String? _courseMinSubscriptionLevel;
  final List<String> _tags = [];

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

      if (!mounted) return;

      if (result == null) {
        Navigator.pop(context);
      } else {
        final snackBar = SnackBar(content: Text(result));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    if (!mounted) return;

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
            hint: 'Type',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a course type';
              }
            },
            onSaved: (value) => _courseCategory = value,
          ),
          const SizedBox(height: 16.0),
          MaterialDropdownButton(
            options: const <String>['Free', 'Standard', 'Premium'],
            initialValue: 'Free',
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
                    child: const Text('CREATE'),
                  ),
          ),
        ],
      ),
    );
  }
}
