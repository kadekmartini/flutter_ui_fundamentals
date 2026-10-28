// Nama: Kadek Martini Aristianti
// NIM: 2415051004
// TAHAP 6: Provider untuk GET dan POST

import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  CourseProvider(this.repository);

  final CourseRepository repository;

  // State daftar course.
  List<Course> courses = [];

  // State loading data.
  bool isLoading = false;

  // State error.
  String? error;

  // State saat menyimpan course baru.
  bool isSaving = false;

  // Mengambil daftar course dari repository.
  Future<void> loadCourses() async {
    isLoading = true;
    error = null;

    notifyListeners();

    try {
      // Delay agar indikator loading terlihat saat praktikum.
      await Future.delayed(const Duration(seconds: 1));

      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Membuat course baru melalui repository.
  Future<Course> createCourse(Course course) async {
    isSaving = true;
    error = null;

    notifyListeners();

    try {
      final createdCourse = await repository.createCourse(course);
      return createdCourse;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}