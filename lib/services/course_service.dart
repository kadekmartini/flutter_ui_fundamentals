import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/course.dart';

class CourseService {
  // TAHAP 9 (Poin 39 & 40): Memindahkan logika baca JSON ke sini
  // Return type-nya wajib berupa Future<List<Course>>
  Future<List<Course>> loadCourses() async {
    final jsonString = await rootBundle.loadString('assets/data/student_data.json');
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['courses'] as List<dynamic>;
    
    // TAHAP 9 (Poin 41 - Opsional): debugPrint untuk menguji sementara
    // debugPrint('Berhasil memuat ${list.length} materi dari Service!');
    
    return list.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }
}