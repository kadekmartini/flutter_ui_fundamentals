import 'package:supabase_flutter/supabase_flutter.dart';

class CourseOwnershipService {
  final SupabaseClient _client;

  CourseOwnershipService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  String _requireUserId() {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.id;
  }

  Future<Set<int>> getMyOwnedCourseIds() async {
    final userId = _requireUserId();

    final rows = await _client
        .from('course_ownership')
        .select('course_id')
        .eq('owner_id', userId);

    return rows.map<int>((row) => (row['course_id'] as num).toInt()).toSet();
  }

  Future<bool> isOwnedByCurrentUser(int courseId) async {
    final userId = _requireUserId();

    final row = await _client
        .from('course_ownership')
        .select('course_id')
        .eq('course_id', courseId)
        .eq('owner_id', userId)
        .maybeSingle();

    return row != null;
  }

  Future<void> registerOwnership(int courseId) async {
    final userId = _requireUserId();

    await _client.from('course_ownership').insert({
      'course_id': courseId,
      'owner_id': userId,
    });
  }

  Future<bool> updateOwnershipTimestamp(int courseId) async {
    _requireUserId();

    final rows = await _client
        .from('course_ownership')
        .update({'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('course_id', courseId)
        .select('course_id');

    return rows.isNotEmpty;
  }

  Future<bool> removeOwnership(int courseId) async {
    _requireUserId();

    final rows = await _client
        .from('course_ownership')
        .delete()
        .eq('course_id', courseId)
        .select('course_id');

    return rows.isNotEmpty;
  }
}
