// lib/screens/course_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // TAHAP 13: Import provider
import '../models/course.dart';
import '../providers/course_state.dart'; // TAHAP 13: Import state
import '../main.dart'; 

class CourseDetailPage extends StatelessWidget {
  final Course course;
  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final String rawStatus = course.status;
    final String statusText = getStatusText(rawStatus);
    final Color statusColor = getStatusColor(rawStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Materi'),
        actions: [
          // TAHAP 13 (Poin 56): Tampilkan status favorite pada DetailPage
          Consumer<CourseState>(
            builder: (context, courseState, child) {
              final isFav = courseState.isFavorite(course.code);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  courseState.toggleFavorite(course.code);
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Judul Materi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(course.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('SKS: ${course.credits}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black12)),
                    
                    const Text('Status Pembelajaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(rawStatus == 'done' ? Icons.check_circle : Icons.pending, color: statusColor, size: 20),
                          const SizedBox(width: 8),
                          Text(statusText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}