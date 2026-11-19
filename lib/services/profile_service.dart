import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isStudent => role == 'student';

  bool get isInstructor => role == 'instructor';

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] as String,
      email: (data['email'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      role: (data['role'] as String?) ?? 'student',
    );
  }
}

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserProfile?> getMyProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _client
        .from('profiles')
        .select('id, email, name, role')
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return UserProfile.fromMap(data);
  }

  Future<List<UserProfile>> getAllProfilesForAdmin() async {
    final currentProfile = await getMyProfile();

    if (currentProfile == null || !currentProfile.isAdmin) {
      throw Exception(
        'Hanya Admin yang dapat melihat seluruh profil pengguna.',
      );
    }

    final data = await _client
        .from('profiles')
        .select('id, email, name, role')
        .order('name');

    return data.map<UserProfile>((item) => UserProfile.fromMap(item)).toList();
  }
}
