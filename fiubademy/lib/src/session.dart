class Session {
  static String? userToken;

  static String? getToken() {
    return userToken;
  }

  static void setToken(String token) {
    userToken = token;
  }
}