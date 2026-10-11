// TAHAP 10: Membuat lapisan abstraksi (Repository Pattern)
import '../models/course.dart';
import '../services/course_service.dart';

class CourseRepository {
  final CourseService service;

  // TAHAP 10: Menerima CourseService melalui constructor
  CourseRepository(this.service);

  // TAHAP 10: Method untuk mengambil data course
  Future<List<Course>> getCourses() {
    return service.loadCourses();
  }
}