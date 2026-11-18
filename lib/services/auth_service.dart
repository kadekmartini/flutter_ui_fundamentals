
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  bool get isLoggedIn => currentSession != null;

  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    String role = 'student',
  }) async {
    final selectedRole =
        role == 'instructor' ? 'instructor' : 'student';

    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'role': selectedRole,
      },
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
