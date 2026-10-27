// Nama: Kadek Martini Aristianti | NIM: 2415051004
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart' show getStatusText, getStatusColor;
import '../models/course.dart';
import '../providers/course_state.dart';
import '../screens/course_detail_page.dart';

class InteractiveCourseCard extends StatelessWidget {
  const InteractiveCourseCard({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseState>();
    final isFavorite = courseState.isFavorite(course.code);
    final statusColor = getStatusColor(course.status);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailPage(course: course),
            ),
          );
        },
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${course.code} • ${course.credits} SKS'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                getStatusText(course.status),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                context.read<CourseState>().toggleFavorite(course.code);
              },
            ),
          ],
        ),
      ),
    );
  }
}