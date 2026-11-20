import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final SupabaseClient _client;

  CourseSupabaseService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  void _requireAuthenticatedUser() {
    if (_client.auth.currentUser == null) {
      throw StateError('Pengguna belum login.');
    }
  }

  @override
  Future<List<Course>> getCourses() async {
    _requireAuthenticatedUser();

    final data = await _client.from('courses').select().order('id');

    return data.map<Course>((row) => Course.fromJson(row)).toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    _requireAuthenticatedUser();

    final row = await _client
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();

    return Course.fromJson(row);
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    _requireAuthenticatedUser();

    final rows = await _client
        .from('courses')
        .update(course.toJson())
        .eq('id', id)
        .select('id');

    if (rows.isEmpty) {
      throw StateError(
        'Kursus tidak ditemukan atau perubahan ditolak oleh RLS.',
      );
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    _requireAuthenticatedUser();

    final rows = await _client
        .from('courses')
        .delete()
        .eq('id', id)
        .select('id');

    if (rows.isEmpty) {
      throw StateError(
        'Kursus tidak ditemukan atau penghapusan ditolak oleh RLS.',
      );
    }
  }
}
