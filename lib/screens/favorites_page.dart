// TAHAP 13 (Poin 57): Buat FavoritesPage yang hanya menampilkan course favorite
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../widgets/course_card.dart';
import '../models/course.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Membaca state daftar materi keseluruhan dan daftar ID materi favorit
    final courseProvider = context.watch<CourseProvider>();
    final courseState = context.watch<CourseState>();

    // Memfilter materi: Hanya ambil materi yang kodenya ada di set favorites
    final List<Course> favoriteCourses = courseProvider.courses
        .where((course) => courseState.isFavorite(course.code))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi Favorit', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: favoriteCourses.isEmpty
          ? const Center(
              child: Text(
                'Belum ada materi favorit.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoriteCourses.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InteractiveCourseCard(course: favoriteCourses[index]),
                );
              },
            ),
    );
  }
}