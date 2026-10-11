// TAHAP 11: Membuat Provider untuk mengelola Async State (Loading, Success, Error)
import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  // TAHAP 11: Menerima repository sebagai dependency
  CourseProvider(this.repository);

  // State yang akan diamati oleh UI
  List<Course> courses = [];
  bool isLoading = false;
  String? error;

  // TAHAP 11: Implementasi loadCourses() dengan pengelolaan state
  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners(); // Beritahu UI untuk menampilkan loading

    try {
      // TAHAP 11: Menambahkan sedikit delay buatan agar efek loading-nya terlihat jelas
      await Future.delayed(const Duration(seconds: 1)); 
      
      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString(); // Tangkap error jika gagal
    } finally {
      isLoading = false;
      notifyListeners(); // Beritahu UI bahwa proses selesai (berhasil/gagal)
    }
  }
}