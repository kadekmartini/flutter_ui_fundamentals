import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  CourseProvider(this.repository);

  final CourseRepository repository;

  List<Course> courses = [];
  bool isLoading = false;
  String? error;
  bool isSaving = false;

  Future<void> loadCourses() async {
    isLoading = true;
    error = null;

    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Course> createCourse(Course course) async {
    isSaving = true;
    error = null;

    notifyListeners();

    try {
      return await repository.createCourse(course);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateCourse(int id, Course course) async {
    isSaving = true;
    error = null;

    notifyListeners();

    try {
      await repository.updateCourse(id, course);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}