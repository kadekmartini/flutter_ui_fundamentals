
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';
import 'course_detail_page.dart';
import 'course_form_page.dart';

class CourseListPage extends StatelessWidget {
  const CourseListPage({super.key});

  Future<void> _openForm(
    BuildContext context, {
    Course? course,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CourseFormPage(course: course),
      ),
    );

    if (result != true || !context.mounted) {
      return;
    }

    final provider = context.read<CourseProvider>();
    await provider.loadCourses();

    if (!context.mounted) {
      return;
    }

    final refreshFailed = provider.error != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          refreshFailed
              ? 'Data tersimpan, tetapi daftar gagal dimuat ulang.'
              : course == null
                  ? 'Course berhasil ditambahkan.'
                  : 'Course berhasil diperbarui.',
        ),
        backgroundColor:
            refreshFailed ? Colors.orange.shade700 : Colors.green.shade700,
      ),
    );
  }

  Future<void> _openDetail(
    BuildContext context,
    Course course,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CourseDetailPage(course: course),
      ),
    );

    if (result == true && context.mounted) {
      await context.read<CourseProvider>().loadCourses();
    }
  }

  Future<void> _deleteCourse(
    BuildContext context,
    Course course,
  ) async {
    if (course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID course tidak ditemukan.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Yakin ingin menghapus "${course.title}" (${course.code})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final provider = context.read<CourseProvider>();
    final favoriteState = context.read<CourseState>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.deleteCourse(course.id!);

      if (favoriteState.isFavorite(course.code)) {
        favoriteState.toggleFavorite(course.code);
      }

      await provider.loadCourses();

      if (!context.mounted) {
        return;
      }

      final refreshFailed = provider.error != null;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            refreshFailed
                ? 'Course dihapus, tetapi daftar gagal dimuat ulang.'
                : 'Course ${course.code} berhasil dihapus.',
          ),
          backgroundColor:
              refreshFailed ? Colors.orange.shade700 : Colors.green.shade700,
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus course: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Widget _buildCourseContent(
    BuildContext context,
    CourseProvider provider,
  ) {
    if (provider.isLoading && provider.courses.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return ErrorView(
        message: provider.error!,
        onRetry: provider.loadCourses,
      );
    }

    if (provider.courses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 60,
                color: Colors.blue.shade300,
              ),
              const SizedBox(height: 12),
              const Text(
                'Belum ada course.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tambahkan course pertama kamu.'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Course'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (provider.isLoading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.loadCourses,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: provider.courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final course = provider.courses[index];

                return InteractiveCourseCard(
                  course: course,
                  onTap: () => _openDetail(context, course),
                  onEdit: () => _openForm(context, course: course),
                  onDelete: () => _deleteCourse(context, course),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        title: const Text(
          'Course Data Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth < 600 ? 16.0 : 28.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    12,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF5FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '2415051004 • Kadek Martini Aristianti',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF23496D),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: provider.isSaving
                              ? null
                              : () => _openForm(context),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Tambah Course',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE6F7F2),
                            foregroundColor: const Color(0xFF00866A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildCourseContent(context, provider),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
