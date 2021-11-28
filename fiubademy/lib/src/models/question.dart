// Yes. This class could definitely be more OOP.
// Feel free to make the changes
import 'dart:js_util';

class Question {
  int _type;
  String _description;
  List<String>? _options;

  Question(int type, String description)
      : _type = 0,
        _description = "" {
    if (type < 0 || type > 3) {
      throw ArgumentError.value(type);
    }
  }

  int get type => _type;
  String typeName(int type) {
    switch (type) {
      case 0:
        return 'Development';
      case 1:
        return 'Multiple Choice';
      case 2:
        return 'Single Choice';
      case 3:
        return 'True or False';
      default:
        return 'Error';
    }
  }

  String get description => _description;
  List<String> get options {
    if (_options == null) {
      throw StateError('Invalid operation for this type of question');
    }
    return _options!;
  }

  set type(int newType) {
    if (newType == _type) return;
    _type = newType;
    if (_type == 0 || _type == 3) {
      _options = null;
    }
  }

  set description(String newDescription) {
    if (newDescription == _description) return;
    _description = newDescription;
  }

  addOption(String newOption) {
    if (_type == 0 || _type == 3) {
      throw TypeError();
    }
    _options ??= [];
    _options!.add(newOption);
  }

  deleteOptionAt(int index) {
    if (_options == null) {
      throw StateError('Invalid operation for this type of question');
    }
  }
}
