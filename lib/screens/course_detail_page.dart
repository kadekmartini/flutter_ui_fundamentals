import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
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

  Future<void> _deleteCourse(BuildContext context) async {
    if (course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Course tidak memiliki ID dan tidak dapat dihapus.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Yakin ingin menghapus "${course.title}" '
            '(${course.code})?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    final CourseProvider provider =
        context.read<CourseProvider>();

    final CourseState courseState =
        context.read<CourseState>();

    try {
      await provider.deleteCourse(course.id!);

      if (!context.mounted) {
        return;
      }

      if (courseState.isFavorite(course.code)) {
        courseState.toggleFavorite(course.code);
      }

      await provider.loadCourses();

      if (!context.mounted) {
        return;
      }

      final bool refreshFailed = provider.error != null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            refreshFailed
                ? 'Course berhasil dihapus, tetapi daftar gagal dimuat ulang.'
                : 'Course ${course.code} berhasil dihapus.',
          ),
          backgroundColor: refreshFailed
              ? Colors.orange.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus course: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          IconButton(
            tooltip: 'Hapus Course',
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: course.id == null
                ? null
                : () => _deleteCourse(context),
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
                  '$studentName • $studentId',
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
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: course.id == null
                              ? null
                              : () => _deleteCourse(context),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Hapus Course'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(
                              color: Colors.red.shade300,
                            ),
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