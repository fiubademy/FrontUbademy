import 'package:ubademy/src/models/question.dart';
import 'package:flutter/material.dart';

class DevelopmentQuestionCard extends FormField<String?> {
  DevelopmentQuestionCard({
    Key? key,
    required Question question,
    required int index,
    FormFieldSetter<String?>? onSaved,
    bool enabled = true,
    String? initialValue,
  }) : super(
          key: key,
          onSaved: onSaved,
          builder: (FormFieldState<String?> state) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                    child: Builder(builder: (context) {
                      return Text('Question ${index + 1}',
                          style: Theme.of(context).textTheme.headline6);
                    }),
                  ),
                  ListTile(
                      title: Text(
                          '${question.description}\n\nWrite your answer:')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: TextField(
                      controller: initialValue == null
                          ? null
                          : TextEditingController(text: initialValue),
                      enabled: enabled,
                      onChanged: (value) {
                        state.didChange(value);
                      },
                      maxLines: null,
                      minLines: 2,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
}

class TrueOrFalseQuestionCard extends FormField<bool> {
  TrueOrFalseQuestionCard({
    Key? key,
    required Question question,
    required int index,
    FormFieldSetter<bool>? onSaved,
    bool enabled = true,
    bool? initialValue,
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          builder: (FormFieldState<bool> state) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                    child: Builder(builder: (context) {
                      return Text('Question ${index + 1}',
                          style: Theme.of(context).textTheme.headline6);
                    }),
                  ),
                  ListTile(
                      title: Text('${question.description}\n\nYour answer:')),
                  RadioListTile<bool>(
                    title: const Text('True'),
                    value: true,
                    groupValue: state.value,
                    onChanged: enabled
                        ? (value) {
                            state.didChange(value);
                          }
                        : null,
                  ),
                  RadioListTile<bool>(
                    title: const Text('False'),
                    value: false,
                    groupValue: state.value,
                    onChanged: enabled
                        ? (value) {
                            state.didChange(value);
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        );
}

class MultipleChoiceQuestionCard extends FormField<Map<String, bool>> {
  MultipleChoiceQuestionCard({
    Key? key,
    required Question question,
    required int index,
    FormFieldSetter<Map<String, bool>>? onSaved,
    FormFieldValidator<Map<String, bool>>? validator,
    required Map<String, bool> initialValue,
    enabled = true,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<Map<String, bool>> state) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                    child: Builder(
                      builder: (context) {
                        return Text('Question ${index + 1}',
                            style: Theme.of(context).textTheme.headline6);
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                        '${question.description}\n\nSelect all the correct options:'),
                  ),
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final oldCheckboxTheme = theme.checkboxTheme;

                      final newCheckBoxTheme = oldCheckboxTheme.copyWith(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                      );
                      return Theme(
                        data: theme.copyWith(checkboxTheme: newCheckBoxTheme),
                        child: Column(
                          children: [
                            for (final option in question.options)
                              CheckboxListTile(
                                title: Text(option),
                                value: state.value![option],
                                onChanged: enabled
                                    ? (checked) {
                                        if (checked == null) return;
                                        state.value![option] = checked;
                                        state.didChange(state.value);
                                      }
                                    : null,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
}

class SingleChoiceQuestionCard extends FormField<String> {
  SingleChoiceQuestionCard(
      {Key? key,
      required Question question,
      required int index,
      FormFieldSetter<String>? onSaved,
      FormFieldValidator<String>? validator,
      bool enabled = true,
      String? initialValue})
      : super(
          key: key,
          onSaved: onSaved,
          initialValue: initialValue,
          validator: validator,
          builder: (FormFieldState<String> state) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                    child: Builder(
                      builder: (context) {
                        return Text('Question ${index + 1}',
                            style: Theme.of(context).textTheme.headline6);
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                        '${question.description}\n\nSelect the correct option:'),
                  ),
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final oldCheckboxTheme = theme.checkboxTheme;

                      final newCheckBoxTheme = oldCheckboxTheme.copyWith(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                      );
                      return Theme(
                        data: theme.copyWith(checkboxTheme: newCheckBoxTheme),
                        child: Column(
                          children: [
                            for (final option in question.options)
                              RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: state.value,
                                onChanged: enabled
                                    ? (selected) {
                                        state.didChange(selected);
                                      }
                                    : null,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
}
