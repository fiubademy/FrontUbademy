import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  String? _userID;
  String _username;
  String _email;
  double? _latitude;
  double? _longitude;
  int _subscriptionLevel;
  DateTime? _subscriptionExpirationDate;
  int _avatarID;

  User()
      : _username = "Not Logged in",
        _email = 'example@mail.com',
        _latitude = 0.0,
        _longitude = 0.0,
        _subscriptionLevel = 0,
        _avatarID = 0,
        _subscriptionExpirationDate = null;

  String? get userID => _userID;
  String get username => _username;
  String get email => _email;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  int get subscriptionLevel => _subscriptionLevel;
  String get subscriptionName {
    switch (_subscriptionLevel) {
      case 0:
        return 'No subscription';
      case 1:
        return 'Standard Subscription';
      case 2:
        return 'Premium Subscription';
      default:
        return 'No subscription';
    }
  }

  void updateData(Map<String, dynamic> newUserData) async {
    _userID = newUserData['user_id'];
    _username = newUserData['username'];
    _email = newUserData['email'];
    _latitude = newUserData['latitude'];
    _longitude = newUserData['longitude'];
    _subscriptionLevel = newUserData['sub_level'];
    _subscriptionExpirationDate = newUserData['sub_expire'] == 'Unlimited'
        ? null
        : DateTime.parse(newUserData['sub_expire']);
    _avatarID = newUserData['avatar'];

    notifyListeners();
  }

  void setPosition(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
  }

  set username(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void deleteData() {
    _userID = null;
    _username = 'Failed to load username';
    _email = 'Failed to load email';
    _latitude = null;
    _longitude = null;
    _subscriptionLevel = 0;
    notifyListeners();
  }

  int get avatarID => _avatarID;

  set avatarID(int newAvatar) {
    _avatarID = newAvatar;
    notifyListeners();
  }

  set subscriptionLevel(int newSubscriptionLevel) {
    _subscriptionLevel = newSubscriptionLevel;
    notifyListeners();
  }

  DateTime? get subscriptionExpirationDate => _subscriptionExpirationDate;

  set subscriptionExpirationDate(DateTime? newDateTime) {
    _subscriptionExpirationDate = newDateTime;
    notifyListeners();
  }

  int get expirationDay => _subscriptionExpirationDate!.day;
  int get expirationYear => _subscriptionExpirationDate!.year;
  String get expirationMonthName {
    switch (_subscriptionExpirationDate!.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        throw StateError('Invalid month number');
    }
  }
}
