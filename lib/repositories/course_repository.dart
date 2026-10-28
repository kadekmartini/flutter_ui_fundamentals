// Nama: Kadek Martini Aristianti
// NIM: 2415051004
// TAHAP 6: Repository untuk GET dan POST

import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  CourseRepository(this.apiService);

  final CourseApiService apiService;

  // Mengambil daftar course.
  Future<List<Course>> getCourses() {
    return apiService.getCourses();
  }

  // Membuat course baru.
  Future<Course> createCourse(Course course) {
    return apiService.createCourse(course);
  }
}