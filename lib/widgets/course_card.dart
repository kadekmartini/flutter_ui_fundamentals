// lib/widgets/course_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_state.dart';
import '../screens/course_detail_page.dart'; // Akan kita buat setelah ini
import '../main.dart'; // Untuk mengakses getStatusText dan getStatusColor

class InteractiveCourseCard extends StatelessWidget {
  final Course course;

  const InteractiveCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final String status = course.status;
    final String statusText = getStatusText(status);
    final Color statusColor = getStatusColor(status);
    final String courseTitle = course.title;

    return Card(
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => CourseDetailPage(course: course)),
          );
          if (!context.mounted) return;
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Materi berhasil dipilih!'), backgroundColor: Colors.green.shade600),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(status == 'done' ? Icons.check_circle : (status == 'active' ? Icons.play_circle : Icons.schedule), color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(courseTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                  ],
                ),
              ),
              Consumer<CourseState>(
                builder: (context, courseState, child) {
                  final isFavorite = courseState.favorites.contains(course.code);
                  
                  return IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey.shade400, size: 26),
                    onPressed: () {
                      context.read<CourseState>().toggleFavorite(course.code);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}