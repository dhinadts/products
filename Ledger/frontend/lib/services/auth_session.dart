import '../models/backend_models.dart';

class AuthSession {
  static AuthResult? _current;

  static AuthResult? get current => _current;
  static String? get token => _current?.token;
  static bool get isAuthenticated => _current?.token.isNotEmpty == true;

  static void save(AuthResult result) {
    _current = result;
  }

  static void clear() {
    _current = null;
  }
}
