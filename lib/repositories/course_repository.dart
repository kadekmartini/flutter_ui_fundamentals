// Nama: Kadek Martini Aristianti | NIM: 2415051004
import '../models/course.dart';
import '../services/course_api_service.dart'; // Import service baru

class CourseRepository {
  // Ubah dependency menjadi CourseApiService
  final CourseApiService apiService;

  CourseRepository(this.apiService);

  Future<List<Course>> getCourses() async {
    // Sesuaikan pemanggilan dari loadCourses() menjadi getCourses()
    return await apiService.getCourses();
  }
}