// Nama: Kadek Martini Aristianti
// NIM: 2415051004
// TAHAP 6: Service Layer untuk HTTP GET dan POST

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';

class CourseApiService {
  CourseApiService(this.baseUrl);

  final String baseUrl;

  // Mengambil daftar course dari API.
  Future<List<Course>> getCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil course. HTTP ${response.statusCode}',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body) as List<dynamic>;

    return data
        .map(
          (item) => Course.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // Menambahkan course baru melalui HTTP POST.
  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Gagal membuat course. HTTP ${response.statusCode}: '
      '${response.body}',
    );
  }
}