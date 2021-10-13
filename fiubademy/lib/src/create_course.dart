import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_tag_editor/tag_editor.dart';

class CreateCoursePage extends StatelessWidget {
  const CreateCoursePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Course'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                child: Column(
                  children: [
                    _buildTitleTextField(),
                    SizedBox(height: 16.0),
                    _buildDescriptionTextField(),
                    SizedBox(height: 16.0),
                    SizedBox(height: 16.0),
                    _buildTypeDropdown(),
                    SizedBox(height: 16.0),
                    _buildSubscriptionDropdown(),
                    SizedBox(height: 16.0),
                    _buildExamNumberField(),
                    SizedBox(height: 16.0),
                    TagsEditor(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleTextField() {
    return TextFormField(
      decoration: const InputDecoration(
          hintText: 'My Brand New Course',
          labelText: 'Title*',
          border: OutlineInputBorder(),
          helperText: '*Required'),
    );
  }

  Widget _buildDescriptionTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'A detailed description about your course',
        labelText: 'Description*',
        hintMaxLines: 2,
        border: OutlineInputBorder(),
      ),
      maxLines: null,
    );
  }

  Widget _buildTypeDropdown() {
    return const MaterialDropdownButton(
        options: <String>['Programming', 'Cooking'], hint: 'Type');
  }

  Widget _buildSubscriptionDropdown() {
    return const MaterialDropdownButton(
      options: <String>['Free', 'Standard', 'Premium'],
      defaultOption: 'Free',
    );
  }

  Widget _buildExamNumberField() {
    return TextFormField(
      decoration: new InputDecoration(
        labelText: 'Exams*',
        hintText: 'Enter the amount of exams',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ], // Only numbers can be entered
    );
  }
}

class TagsEditor extends StatefulWidget {
  const TagsEditor({Key? key}) : super(key: key);

  @override
  _TagsEditorState createState() => _TagsEditorState();
}

class _TagsEditorState extends State<TagsEditor> {
  List<String> values = [];

  @override
  Widget build(BuildContext context) {
    return TagEditor(
      length: values.length,
      delimiters: [',', ' '],
      hasAddButton: true,
      inputDecoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(12.0, 12.0,0,0),
        border: InputBorder.none,
        hintText: 'Tags...',
      ),
      onTagChanged: (newValue) {
        setState(() {
          values.add(newValue);
        });
      },
      tagBuilder: (context, index) => Chip(
        label: Text(values[index]),
        onDeleted: () {
          setState(() {
            values.removeWhere((element) => element == values[index]);
          });
        },
      ),
    );
  }
}

class MaterialDropdownButton extends StatefulWidget {
  final List<String> options;
  final String? hint;
  final String? defaultOption;

  const MaterialDropdownButton(
      {Key? key, required this.options, this.hint, this.defaultOption})
      : super(key: key);

  @override
  _MaterialDropdownButtonState createState() => _MaterialDropdownButtonState();
}

class _MaterialDropdownButtonState extends State<MaterialDropdownButton> {
  String? _currentSelectedValue;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
            errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
            hintText: widget.hint,
            border: OutlineInputBorder(),
          ),
          isEmpty: _currentSelectedValue == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentSelectedValue ?? widget.defaultOption,
              isDense: true,
              onChanged: (String? newValue) {
                setState(() {
                  _currentSelectedValue = newValue!;
                  state.didChange(newValue);
                });
              },
              items: widget.options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
