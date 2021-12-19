import 'package:flutter/material.dart';

class MaterialDropdownButton extends FormField<String> {
  final List<String> options;
  final String? hint;
  final String? defaultOption;

  MaterialDropdownButton({
    Key? key,
    required this.options,
    this.hint,
    this.defaultOption,
    bool enabled = true,
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
