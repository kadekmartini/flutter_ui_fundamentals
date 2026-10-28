import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_state.dart';
import '../main.dart';
import 'edit_course_page.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({
    super.key,
    required this.course,
  });

  final Course course;

  Future<void> _openEditPage(BuildContext context) async {
    if (course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Course tidak memiliki ID dan tidak dapat diedit.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool? updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EditCoursePage(course: course),
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (updated == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String rawStatus = course.status;
    final String statusText = getStatusText(rawStatus);
    final Color statusColor = getStatusColor(rawStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Materi'),
        actions: [
          IconButton(
            tooltip: 'Edit Course',
            icon: const Icon(Icons.edit_outlined),
            onPressed: course.id == null
                ? null
                : () => _openEditPage(context),
          ),
          Consumer<CourseState>(
            builder: (context, courseState, child) {
              final bool isFavorite =
                  courseState.isFavorite(course.code);

              return IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari Favorit'
                    : 'Tambahkan ke Favorit',
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Kadek Martini Aristianti • 2415051004',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white,
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kode Course',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.code,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Judul Materi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SKS: ${course.credits}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.black12),
                      ),
                      const Text(
                        'Status Pembelajaran',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              rawStatus == 'done'
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color: statusColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: course.id == null
                              ? null
                              : () => _openEditPage(context),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Course'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}