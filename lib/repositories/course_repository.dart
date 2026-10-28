import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  CourseRepository(this.apiService);

  final CourseApiService apiService;

  Future<List<Course>> getCourses() {
    return apiService.getCourses();
  }

  Future<Course> createCourse(Course course) {
    return apiService.createCourse(course);
  }

  Future<void> updateCourse(int id, Course course) {
    return apiService.updateCourse(id, course);
  }
}