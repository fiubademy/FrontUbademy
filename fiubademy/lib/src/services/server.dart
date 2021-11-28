import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:fiubademy/src/services/auth.dart';

class Server {
  // TODO Check which methods return 422 and kill the session of Auth
  static const int _invalidToken = 498;
  static const String url = "api-gateway-fiubademy.herokuapp.com";

  static bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  /* Logs in to the account. Updates auth */

  static Future<String?> login(Auth auth, String email, String password) async {
    final Map<String, String> queryParams = {
      'email': email,
      'password': password,
    };
    final response = await http.post(
      Uri.https(url, "/users/login", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
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

  /* Creates a new user. Returns null on success, an error message otherwise */

  static Future<String?> signup(
      String username, String email, String password) async {
    final Map<String, String> queryParams = {
      'username': username,
      'email': email,
      'password': password,
    };
    final response = await http.post(
      Uri.https(url, "/users/", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
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

  /* Gets a user, given my permissions */

  static Future<Map<String, dynamic>?> getUser(Auth auth, String userID) async {
    final Map<String, String> queryParams = {
      'user_id': userID,
    };
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
    final Map<String, String> queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };
    final response = await http.get(
      Uri.https(url, "/users/${auth.userToken}/set_location", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case HttpStatus.accepted:
        return true;
      default:
        return false;
    }
  }

  /* Enrolls self to a course. Returns null on success. An error message otherwise. */

  static Future<String?> enrollToCourse(Auth auth, String courseID) async {
    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
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
      case HttpStatus.notFound:
        return 'Failed to enroll. Please try again in a few minutes';
      case _invalidToken:
        auth.deleteAuth();
        return 'Invalid credentials. Please login again';
      default:
        return 'Failed to enroll. Please try again in a few minutes';
    }
  }

  /* Unsubscribes self from the course. Returns null on success, an error message otherwise. */

  static Future<String?> unsubscribeFromCourse(
      Auth auth, String courseID) async {
    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
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
        return 'Invalid credentials. Please login again';
      case HttpStatus.notFound:
        return 'Failed to unsubscribe. Please try again in a few minutes';
      default:
        return 'Failed to unsubscribe. Please try again in a few minutes';
    }
  }

  /* Adds a collaborator, given I'm the owner. Returns null on success, an error message otherwise. */

  static Future<String?> addCollaborator(
      Auth auth, String collaboratorID, String courseID) async {
    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
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
        return 'Invalid credentials. Please login again';
      case HttpStatus.notFound:
        return 'Failed to add collaborator. Please try again in a few minutes';
      case HttpStatus.conflict:
        return 'Failed to add collaborator. User is already a collaborator';
      default:
        return 'Failed to add collaborator. Please try again in a few minutes';
    }
  }

  /* Removes self from the collaborators of the course.
   * Returns null on success, an error message otherwise */

  static Future<String?> unsubscribeCollaborator(
      Auth auth, String courseID) async {
    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
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
        return 'Invalid credentials. Please login again';
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
    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
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
        return 'Invalid credentials. Please login again';
      case HttpStatus.unauthorized:
        return 'Failed to remove collaborator. Not enough permissions';
      case HttpStatus.notFound:
        return 'Failed to remove collaborator. Please try again in a few minutes';
      default:
        return 'Failed to remove collaborator. Please try again in a few minutes';
    }
  }

  /* Returns a list of courses in the page. Returns null in case of error. */

  static Future<List<Map<String, dynamic>>?> getCourses(
      Auth auth, int page) async {
    final Map<String, String> queryParams = {
      'sessionToken': auth.userToken!,
    };
    final response = await http.get(
      Uri.https(url, "/courses/all/$page", queryParams),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    switch (response.statusCode) {
      case 200:
        Map<String, dynamic> body = jsonDecode(response.body);
        List<Map<String, dynamic>> courses = body["content"];
        return courses;
      default:
        return null;
    }
  }
}
