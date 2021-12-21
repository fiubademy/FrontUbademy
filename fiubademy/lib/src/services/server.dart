import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:fiubademy/src/services/auth.dart';

class Server {
  static const int _invalidToken = 498;
  static const String url = "api-gateway-fiubademy.herokuapp.com";

  static bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  /* Logs in to the account. Updates auth */

  static Future<String?> login(Auth auth, String email, String password) async {
    final Map<String, String> body = {
      'email': email,
      'password': password,
    };
    final response = await http.post(
      Uri.https(url, "/users/login"),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> body = jsonDecode(response.body);
        auth.setAuth(body['userID'], body['sessionToken']);
        return null;
      case HttpStatus.unauthorized:
        return 'Invalid credentials';
      case HttpStatus.forbidden:
        return 'The account has been blocked blocked';
      default:
        return 'Failed to log in. Please try again in a few minutes';
    }
  }

  /* Logs in to the account using google. Updates auth */

  static Future<String?> loginWithGoogle(
      Auth auth, String email, String displayName, String googleID) async {
    final Map<String, String> body = {
      'idGoogle': googleID,
      'username': displayName,
      'email': email,
    };
    final response = await http.post(
      Uri.https(url, "/users/loginGoogle"),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    switch (response.statusCode) {
      case HttpStatus.created:
      case HttpStatus.accepted:
        Map<String, dynamic> body = jsonDecode(response.body);
        auth.setAuth(body['user_id'], body['sessionToken']);
        return null;
      case HttpStatus.notAcceptable:
      case HttpStatus.notFound:
        return 'Failed to log in with Google. Please try again';
      case HttpStatus.unauthorized:
        return 'Failed to log in with Google. Account credentials are incompatible';
      default:
        return 'Failed to log in with Google. Please try again in a few minutes.';
    }
  }

  /* Creates a new user. Returns null on success, an error message otherwise */

  static Future<String?> signup(
      String username, String email, String password) async {
    final Map<String, String> body = {
      'username': username,
      'email': email,
      'password': password,
    };
    final response = await http.post(
      Uri.https(url, "/users/"),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    switch (response.statusCode) {
      case HttpStatus.created:
        return null;
      case HttpStatus.notAcceptable:
        return 'The account already exists';
      default:
        return 'Failed to sign up. Please try again in a few minutes';
    }
  }

  /* Logs out the user manually */

  static Future<bool> logout(Auth auth) async {
    if (auth.userToken == null) return false;

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.delete(
      Uri.https(url, "/users/logout/", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return true;
      default:
        return false;
    }
  }

  /* Gets a user, given my permissions */

  static Future<Map<String, dynamic>?> getUser(Auth auth, String userID) async {
    if (auth.userToken == null) return null;

    final response = await http.get(
      Uri.https(url, "/users/ID/$userID"),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return jsonDecode(response.body);
      default:
        return null;
    }
  }

  /* Updates self's position. Returns true on success, false otherwise. */

  static Future<bool> updatePosition(
      Auth auth, double latitude, double longitude) async {
    if (auth.userToken == null) return false;

    final Map<String, String> body = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };
    final response = await http.patch(
      Uri.https(url, "/users/${auth.userToken}/set_location"),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return true;
      case _invalidToken:
        auth.deleteAuth();
        return false;
      default:
        return false;
    }
  }

  /* Enrolls self to a course. Returns null on success. An error message otherwise. */

  static Future<String?> enrollToCourse(Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.post(
      Uri.https(url, "/courses/id/$courseID/enroll", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.created:
        return null;
      case HttpStatus.conflict:
        return 'Failed to enroll. Already enrolled. Please restart the app';
      case HttpStatus.forbidden:
        return 'Failed to enroll. Subscription level not high enough';
      case HttpStatus.notFound:
        return 'Failed to enroll. Please try again in a few minutes';
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to enroll. Please try again in a few minutes';
    }
  }

  /* Unsubscribes self from the course. Returns null on success, an error message otherwise. */

  static Future<String?> unsubscribeFromCourse(
      Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.delete(
      Uri.https(url, "/courses/id/$courseID/unsubscribe", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      case HttpStatus.notFound:
      default:
        return 'Failed to unsubscribe. Please try again in a few minutes';
    }
  }

  /* Adds a collaborator, given I'm the owner. Returns null on success, an error message otherwise. */

  static Future<String?> addCollaborator(
      Auth auth, String collaboratorID, String courseID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.post(
      Uri.https(url, "/courses/id/$courseID/add_collaborator/$collaboratorID",
          queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.created:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      case HttpStatus.notFound:
        return 'Failed to add collaborator. User does not exist';
      case HttpStatus.conflict:
        return 'Failed to add collaborator. User is already a collaborator or student';
      default:
        return 'Failed to add collaborator. Please try again in a few minutes';
    }
  }

  /* Removes self from the collaborators of the course.
   * Returns null on success, an error message otherwise */

  static Future<String?> unsubscribeCollaborator(
      Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.delete(
      Uri.https(
          url, "/courses/id/$courseID/unsubscribe_collaborator", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      case HttpStatus.notFound:
        return 'Failed to unsubscribe as collaborator. Please try again in a few minutes';
      default:
        return 'Failed to unsubscribe as collaborator. Please try again in a few minutes';
    }
  }

  /* Removes a collaborator from the course, given I'm the owner.
   * Returns null on success, an error message otherwise. */

  static Future<String?> removeCollaborator(
      Auth auth, String collaboratorID, String courseID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.delete(
      Uri.https(
          url,
          "/courses/id/$courseID/remove_collaborator/$collaboratorID",
          queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      case HttpStatus.unauthorized:
        return 'Failed to remove collaborator. Not enough permissions';
      case HttpStatus.notFound:
        return 'Failed to remove collaborator. Please refresh the list';
      default:
        return 'Failed to remove collaborator. Please try again in a few minutes';
    }
  }

  /* Returns a list of courses in the page. Returns null in case of error. */

  static Future<Map<String, dynamic>> getCourses(Auth auth, int page,
      {String? title, int? subLevel, String? category}) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, dynamic> queryParams = {
      'sessionToken': auth.userToken!,
    };
    if (title != null) queryParams['name'] = title;
    if (subLevel != null) queryParams['sub_level'] = subLevel.toString();
    if (category != null) queryParams['category'] = category;
    final response = await http.get(
      Uri.https(url, "/courses/all/$page", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> body = jsonDecode(response.body);
        body['error'] = null;
        return body;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again'
        };
        return map;
      default:
        Map<String, dynamic> map = {
          'error': 'Failed to get courses. Please try again in a few minutes'
        };
        return map;
    }
  }

  /* Returns a list of courses in the page. Returns null in case of error. */

  static Future<Map<String, dynamic>?> getCourse(
      Auth auth, String courseID) async {
    if (auth.userToken == null) return null;

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
      'id': courseID,
    };
    final response = await http.get(
      Uri.https(url, "/courses/all/1", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> body = jsonDecode(response.body);
        List<Map<String, dynamic>> courses = body["content"];
        if (courses.length == 1) {
          return courses[0];
        } else {
          return null;
        }
      default:
        return null;
    }
  }

  /* Returns a list of courses which you own, null on error. */

  static Future<Map<String, dynamic>> getMyOwnedCourses(
      Auth auth, int page) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
      Uri.https(url, "/courses/my_courses/owner/$page", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> body = jsonDecode(response.body);
        body['error'] = null;
        return body;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again'
        };
        return map;
      default:
        Map<String, dynamic> map = {
          'error': 'Failed to get courses. Please try again in a few minutes'
        };
        return map;
    }
  }

  /* Returns a list of courses in which you are collaborating, null on error. */

  static Future<Map<String, dynamic>> getMyCollaborationCourses(
      Auth auth, int page) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
      Uri.https(url, "/courses/my_courses/collaborator/$page", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> body = jsonDecode(response.body);
        body['error'] = null;
        return body;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again'
        };
        return map;
      default:
        Map<String, dynamic> map = {
          'error': 'Failed to get courses. Please try again in a few minutes'
        };
        return map;
    }
  }

  /* Returns a list of courses in which you are enrolled, null on error. */

  static Future<Map<String, dynamic>> getMyEnrolledCourses(
      Auth auth, int page) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
      Uri.https(url, "/courses/my_courses/$page", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> body = jsonDecode(response.body);
        body['error'] = null;
        return body;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again'
        };
        return map;
      default:
        Map<String, dynamic> map = {
          'error': 'Failed to get courses. Please try again in a few minutes'
        };
        return map;
    }
  }

  static Future<Map<String, dynamic>> getMyFavouriteCourses(
      Auth auth, int page) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
      Uri.https(url, "/courses/my_fav_courses/$page", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> body = jsonDecode(response.body);
        body['error'] = null;
        return body;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again'
        };
        return map;
      default:
        Map<String, dynamic> map = {
          'error': 'Failed to get courses. Please try again in a few minutes'
        };
        return map;
    }
  }

  /* Returns a list of studentsIDs in the course, null on error. */

  static Future<Map<String, dynamic>> getCourseStudents(
      Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
      Uri.https(url, "/courses/id/$courseID/students", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        List<String> body = List<String>.from(jsonDecode(response.body));
        Map<String, dynamic> map = {'error': null, 'content': body};
        return map;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again'
        };
        return map;
      default:
        Map<String, dynamic> map = {
          'error':
              'Failed to get collaborators. Please try again in a few minutes'
        };
        return map;
    }
  }

  /* Returns a list of collaboratorIDs in the course, null on error. */

  static Future<Map<String, dynamic>> getCourseCollaborators(
      Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
      Uri.https(url, "/courses/id/$courseID/collaborators", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        List<String> body = List<String>.from(jsonDecode(response.body));
        Map<String, dynamic> map = {'error': null, 'content': body};
        return map;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again'
        };
        return map;
      default:
        Map<String, dynamic> map = {
          'error':
              'Failed to get collaborators. Please try again in a few minutes'
        };
        return map;
    }
  }

  static Future<String?> createCourse(
      Auth auth,
      String name,
      String description,
      String category,
      List<String> hashtags,
      int minSubscription,
      double latitude,
      double longitude) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };

    Map<String, dynamic> requestBody = {
      "name": name,
      "description": description,
      "hashtags": hashtags,
      "sub_level": minSubscription,
      "latitude": latitude,
      "longitude": longitude,
      "category": category,
    };

    final response = await http.post(
      Uri.https(url, "/courses", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to create course. Please try again.';
    }
  }

  static Future<String?> updateCourse(Auth auth,
      {required String courseID,
      required String name,
      required String description,
      required String category,
      required List<String> hashtags,
      required int minSubscription}) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };

    Map<String, dynamic> requestBody = {
      "name": name,
      "description": description,
      "hashtags": hashtags,
      "sub_level": minSubscription,
      "category": category,
    };

    final response = await http.patch(
      Uri.https(url, "/courses/id/$courseID", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to edit course. Please try again.';
    }
  }

  /* Edits User's Username in the API. Returns null on success or an error string in failure. */

  static Future<String?> updateProfile(Auth auth, String newUsername) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> body = {'username': newUsername};
    final response =
        await http.patch(Uri.https(url, "/users/${auth.userToken}"),
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: jsonEncode(body));
    switch (response.statusCode) {
      case HttpStatus.ok:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to edit username. Please try again in a few minutes';
    }
  }

  /* Changes user password when giving it the correct old user's password. Returns null on error or an error string on failure. */

  static Future<String?> changePassword(
      Auth auth, String oldPassword, String newPassword) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> body = {
      "oldPassword": oldPassword,
      "newPassword": newPassword
    };
    final response = await http.patch(
        Uri.https(url, "/users/changePassword/${auth.userToken}"),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(body));

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return null;
      case HttpStatus.notAcceptable:
        return 'Failed to change password. New password must have 8 or more characters.';
      case HttpStatus.badRequest:
        return 'Failed to change password. Your old Password is not correct.';
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to change password. Please try again in a few minutes';
    }
  }

  static Future<String?> updateAvatar(Auth auth, int newAvatarID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final response = await http.patch(
      Uri.https(url, "/users/${auth.userToken}/set_avatar/$newAvatarID"),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to update avatar. Please try again in a few minutes';
    }
  }

  static Future<bool> isEnrolled(Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return false;
    }

    final Map<String, String> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    final response = await http.get(
      Uri.https(url, "/courses/my_courses/1", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> body = jsonDecode(response.body);
        List<Map<String, dynamic>> courses =
            List<Map<String, dynamic>>.from(body["content"]);
        return courses.isNotEmpty;
      case _invalidToken:
        auth.deleteAuth();
        return false;
      default:
        return false;
    }
  }

  static Future<bool> isCollaborator(Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return false;
    }

    final Map<String, String> queryParams = {
      'courseIdFilter': courseID,
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
      Uri.https(url, "/courses/my_courses/collaborator/1", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> body = jsonDecode(response.body);
        List<Map<String, dynamic>> courses =
            List<Map<String, dynamic>>.from(body["content"]);
        return courses.isNotEmpty;
      case _invalidToken:
        auth.deleteAuth();
        return false;
      default:
        return false;
    }
  }

  static Future<bool> isFavourite(Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return false;
    }

    final Map<String, String> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
      Uri.https(url, "/courses/my_fav_courses/1", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> body = jsonDecode(response.body);
        List<Map<String, dynamic>> courses =
            List<Map<String, dynamic>>.from(body["content"]);
        return courses.isNotEmpty;
      case _invalidToken:
        auth.deleteAuth();
        return false;
      default:
        return false;
    }
  }

  static Future<String?> addFavourite(Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, dynamic> queryParams = {
      'fav': 'true',
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };
    final response = await http.put(
      Uri.https(url, "/courses/new_fav", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to add to favourite. Please try again in a few minutes';
    }
  }

  static Future<String?> removeFavourite(Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, dynamic> queryParams = {
      'fav': 'false',
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };
    final response = await http.put(
      Uri.https(url, "/courses/new_fav", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to remove to favourite. Please try again in a few minutes';
    }
  }

  static Future<String?> publishCourse(Auth auth, String courseID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, dynamic> queryParams = {
      'in_edition': 'false',
      'sessionToken': auth.userToken!,
    };
    final response = await http.put(
      Uri.https(url, "/courses/id/$courseID/status", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to publish course. Please try again in a few minutes';
    }
  }

  static Future<Map<String, dynamic>> createExam(
      Auth auth, String courseID, String examTitle) async {
    if (auth.userToken == null) {
      return {
        'error': 'Invalid credentials. Please log in again',
        'content': null,
      };
    }

    final Map<String, dynamic> queryParams = {
      'sessionToken': auth.userToken!,
    };

    final Map<String, dynamic> body = {
      'examDate': DateTime.now().toIso8601String(),
      'examTitle': examTitle,
    };

    final response = await http.post(
      Uri.https(url, "/exams/create_exam/$courseID", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> map = {
          'error': null,
          'content': jsonDecode(response.body)['exam_id'],
        };
        return map;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again',
          'content': null,
        };
        return map;
      default:
        Map<String, dynamic> map = {
          'error': 'Failed to create exam. Please try again in a few minutes',
          'content': null,
        };
        return map;
    }
  }

  static Future<String?> updateExam(
      Auth auth, String courseID, String examID, String examTitle) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    Map<String, dynamic> body = {
      'exam_title': examTitle,
    };

    final response = await http.patch(
      Uri.https(url, "/exams/edit_exam/$examID", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );
    switch (response.statusCode) {
      case HttpStatus.accepted:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to edit exam title. Please try again.';
    }
  }

  static Future<String?> deleteExam(
      Auth auth, String courseID, String examID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, String> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    final response = await http.delete(
      Uri.https(url, "/exams/$examID", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please login again';
      default:
        return 'Failed to delete exam. Please try again.';
    }
  }

  static Future<Map<String, dynamic>> addExamQuestion(
      Auth auth,
      String courseID,
      String examID,
      String questionType,
      String questionDescription,
      List<String> questionOptions) async {
    if (auth.userToken == null) {
      return {
        'error': 'Invalid credentials. Please log in again',
        'content': null,
      };
    }

    final Map<String, dynamic> queryParams = {
      'exam_id': examID,
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    String type;
    switch (questionType) {
      case 'Development':
        type = 'DES';
        break;
      case 'Multiple Choice':
        type = 'MC';
        break;
      case 'Single Choice':
        type = 'SC';
        break;
      case 'True or False':
        type = 'VOF';
        break;
      default:
        throw Error();
    }

    if (questionType == 'True or False') {
      questionOptions.add('True');
      questionOptions.add('False');
    }

    List<Map<String, dynamic>> options = [];
    for (int i = 0; i < questionOptions.length; i++) {
      options.add({
        'number': i,
        'content': questionOptions[i],
      });
    }

    final Map<String, dynamic> body = {
      'question_type': type,
      'question_content': questionDescription,
      'choice_responses': options,
    };

    final response = await http.post(
      Uri.https(url, "/exams/$examID/add_question", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> map = {
          'error': null,
          'content': jsonDecode(response.body)['question_id'],
        };
        return map;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again',
          'content': null,
        };
        return map;
      case HttpStatus.badRequest:
        Map<String, dynamic> map = {
          'error': 'Failed to create question. Invalid fields',
          'content': null,
        };
        return map;
      default:
        Map<String, dynamic> map = {
          'error':
              'Failed to create question. Please try again in a few minutes',
          'content': null,
        };
        return map;
    }
  }

  static Future<String?> deleteExamQuestion(
    Auth auth,
    String courseID,
    String questionID,
  ) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, dynamic> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    final response = await http.delete(
      Uri.https(url, "/exams/questions/$questionID", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      case HttpStatus.notFound:
        return 'Failed to delete question. Question does not exist';
      default:
        return 'Failed to delete question. Please try again in a few minutes';
    }
  }

  static Future<String?> updateExamQuestion(
      Auth auth,
      String courseID,
      String questionID,
      String questionType,
      String questionDescription,
      List<String> questionOptions) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, dynamic> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    String type;
    switch (questionType) {
      case 'Development':
        type = 'DES';
        break;
      case 'Multiple Choice':
        type = 'MC';
        break;
      case 'Single Choice':
        type = 'SC';
        break;
      case 'True or False':
        type = 'VOF';
        break;
      default:
        throw Error();
    }

    List<Map<String, dynamic>> options = [];
    for (int i = 0; i < questionOptions.length; i++) {
      options.add({
        'number': i,
        'content': questionOptions[i],
      });
    }
    if (questionType == 'True or False') {
      options.add({
        'number': 0,
        'content': 'True',
      });
      options.add({
        'number': 1,
        'content': 'False',
      });
    }

    final Map<String, dynamic> body = {
      'question_type': type,
      'question_content': questionDescription,
      'choice_responses': options,
    };

    final response = await http.patch(
      Uri.https(url, "/exams/edit_question/$questionID", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      case HttpStatus.badRequest:
        return 'Failed to update question. Invalid fields';
      default:
        return 'Failed to update question. Please try again in a few minutes';
    }
  }

  static Future<Map<String, dynamic>> getExams(Auth auth, String courseID,
      {String? state}) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, dynamic> queryParams = {
      'sessionToken': auth.userToken!,
    };

    if (state != null) queryParams['exam_status'] = state;

    final response = await http.get(
      Uri.https(url, "/exams/course/$courseID", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        List<dynamic> body = jsonDecode(response.body);
        Map<String, dynamic> map = {
          'error': null,
          'content': body,
        };
        return map;
      case HttpStatus.notFound:
        Map<String, dynamic> map = {
          'error': null,
          'content': [],
        };
        return map;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again'
        };
        return map;
      default:
        Map<String, dynamic> map = {
          'error': 'Failed to get exams. Please try again in a few minutes'
        };
        return map;
    }
  }

  static Future<Map<String, dynamic>> getExamQuestions(
      Auth auth, String courseID, String examID) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, dynamic> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    final response = await http.get(
      Uri.https(url, "/exams/$examID/questions", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        List<dynamic> body = jsonDecode(response.body);
        Map<String, dynamic> map = {
          'error': null,
          'content': body,
        };
        return map;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again'
        };
        return map;
      case HttpStatus.notFound:
        return {'error': null, 'content': []};
      default:
        Map<String, dynamic> map = {
          'error':
              'Failed to get exam questions. Please try again in a few minutes'
        };
        return map;
    }
  }

  static Future<String?> publishExam(
      Auth auth, String courseID, String examID) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, dynamic> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    final response = await http.patch(
      Uri.https(url, "/exams/$examID/publish", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to publish exam. Please try again in a few minutes';
    }
  }

  static Future<Map<String, dynamic>> getUncorrectedExams(
      Auth auth, String courseID, String examID) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, dynamic> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    final response = await http.get(
      Uri.https(
          url, "/exams/$examID/students_without_qualification", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        List<dynamic> body = jsonDecode(response.body);
        Map<String, dynamic> map = {
          'error': null,
          'content': body,
        };
        return map;
      case _invalidToken:
        auth.deleteAuth();
        Map<String, dynamic> map = {
          'error': 'Invalid credentials. Please log in again'
        };
        return map;
      case HttpStatus.notFound:
        String errMsg = jsonDecode(response.body);
        if (errMsg == 'No users have answered this exam yet.') {
          return {
            'error': null,
            'content': [],
          };
        }
        return {
          'error':
              'Failed to get exams awaiting correction. Please try again in a few minutes'
        };
      default:
        Map<String, dynamic> map = {
          'error':
              'Failed to get exams awaiting correction. Please try again in a few minutes'
        };
        return map;
    }
  }

  static Future<String?> submitQuestionAnswer(Auth auth, String courseID,
      String examID, String questionID, String questionAnswer) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, dynamic> queryParams = {
      'courseId': courseID,
      'user_id': auth.userID!,
      'sessionToken': auth.userToken!,
    };

    final Map<String, dynamic> body = {
      'response_content': questionAnswer,
    };

    final response = await http.post(
      Uri.https(url, "/exams/$examID/answer/$questionID", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      case HttpStatus.forbidden:
        return 'Failed to submit exam answer. Already submitted';
      default:
        return 'Failed to submit exam answer. Please try again in a few minutes';
    }
  }

  static Future<Map<String, dynamic>> getQuestionAnswer(
    Auth auth,
    String courseID,
    String questionID,
    String userID,
  ) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, dynamic> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    final response = await http.get(
      Uri.https(url, "/exams/student/$userID/student_response/$questionID",
          queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return {
          'error': null,
          'content': jsonDecode(response.body)['response_content']
        };
      case _invalidToken:
        auth.deleteAuth();
        return {'error': 'Invalid credentials. Please log in again'};
      default:
        return {
          'error':
              'Failed to load student\'s answer. Please try again in a few minutes'
        };
    }
  }

  static Future<Map<String, dynamic>> markExam(
    Auth auth,
    String courseID,
    String examID,
    String userID,
    int mark,
    String feedback,
  ) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, dynamic> queryParams = {
      'courseId': courseID,
      'sessionToken': auth.userToken!,
    };

    final Map<String, dynamic> body = {
      'mark': mark,
      'comments': feedback,
    };

    final response = await http.post(
      Uri.https(url, "/exams/$examID/qualify/$userID", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    switch (response.statusCode) {
      case HttpStatus.created:
        return {'error': null, 'content': jsonDecode(response.body)};
      case _invalidToken:
        auth.deleteAuth();
        return {'error': 'Invalid credentials. Please log in again'};
      case HttpStatus.badRequest:
        return {'error': 'Failed to mark exam. Exam already corrected'};
      default:
        return {
          'error': 'Failed to mark exam. Please try again in a few minutes'
        };
    }
  }

  static Future<Map<String, dynamic>> getWallet(Auth auth) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final response = await http.get(
      Uri.https(url, '/payments/wallet/${auth.userToken}'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return {'error': null, 'content': jsonDecode(response.body)};
      case _invalidToken:
        auth.deleteAuth();
        return {'error': 'Invalid credentials. Please log in again'};
      case HttpStatus.notFound:
        return {'error': 'Failed to get wallet. User has no wallet'};
      default:
        return {
          'error': 'Failed to get wallet. Please try again in a few minutes'
        };
    }
  }

  static Future<Map<String, dynamic>> createWallet(Auth auth) async {
    if (auth.userToken == null) {
      return {'error': 'Invalid credentials. Please log in again'};
    }

    final Map<String, dynamic> queryParams = {
      'sessionToken': auth.userToken!,
    };

    final response = await http.post(
      Uri.https(url, '/payments/wallet', queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return {'error': null, 'content': jsonDecode(response.body)};
      case _invalidToken:
        auth.deleteAuth();
        return {'error': 'Invalid credentials. Please log in again'};
      default:
        return {
          'error': 'Failed to get wallet. Please try again in a few minutes'
        };
    }
  }

  static Future<String?> paySubscription(
      Auth auth, int subscriptionLevel) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, dynamic> queryParams = {
      'sessionToken': auth.userToken!,
    };

    // Wallet starts with 0.00100;
    double price = 0;
    if (subscriptionLevel == 1) {
      price = 0.00010;
    } else if (subscriptionLevel == 2) {
      price = 0.00015;
    }

    final Map<String, dynamic> body = {
      'amount_ether': price,
    };

    final response = await http.post(
      Uri.https(url, '/payments/deposit', queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );

    switch (response.statusCode) {
      case HttpStatus.ok:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to pay for subscription. Please try again in a few minutes';
    }
  }

  static Future<String?> updateSubscription(
      Auth auth, int subscriptionLevel) async {
    if (auth.userToken == null) {
      return 'Invalid credentials. Please log in again';
    }

    final Map<String, dynamic> body = {
      'sub_level': subscriptionLevel,
    };

    final response =
        await http.post(Uri.https(url, '/users/${auth.userToken!}/pay_sub'),
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: jsonEncode(body));

    switch (response.statusCode) {
      case HttpStatus.ok:
        return null;
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please log in again';
      default:
        return 'Failed to pay for subscription. Please try again in a few minutes';
    }
  }

  static Future<double?> getWalletBalance(String walletAddress) async {
    final Map<String, String> queryParams = {
      'module': 'account',
      'action': 'balance',
      'address': walletAddress,
      'tag': 'latest',
      'apiKey': 'RX87NMP9SGP3BUVPSWI3WTTUVUINRUS399',
    };

    final response = await http.get(
      Uri.https('api-kovan.etherscan.io', '/api', queryParams),
    );

    if (response.statusCode == HttpStatus.ok) {
      int digits = int.parse(jsonDecode(response.body)['result']);
      return digits / pow(10, 18);
    } else {
      return null;
    }
  }
}
