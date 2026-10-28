
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import 'course_form_page.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late Course _course;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
  }

  String _statusText(String status) {
    switch (status) {
      case 'done':
        return 'Selesai';
      case 'active':
        return 'Berjalan';
      default:
        return 'Terencana';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'done':
        return Colors.green.shade700;
      case 'active':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Future<void> _editCourse() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CourseFormPage(course: _course),
      ),
    );

    if (result != true || !mounted) {
      return;
    }

    final provider = context.read<CourseProvider>();
    await provider.loadCourses();

    if (!mounted) {
      return;
    }

    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Perubahan tersimpan, tetapi detail gagal dimuat ulang.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final updatedCourses = provider.courses
        .where((item) => item.id == _course.id)
        .toList();

    if (updatedCourses.isNotEmpty) {
      setState(() {
        _course = updatedCourses.first;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course berhasil diperbarui.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteCourse() async {
    if (_course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID course tidak ditemukan.'),
          backgroundColor: Colors.red,
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
            'Yakin ingin menghapus "${_course.title}" (${_course.code})?',
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

    if (confirmed != true || !mounted) {
      return;
    }

    final provider = context.read<CourseProvider>();
    final favoriteState = context.read<CourseState>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.deleteCourse(_course.id!);

      if (favoriteState.isFavorite(_course.code)) {
        favoriteState.toggleFavorite(_course.code);
      }

      await provider.loadCourses();

      if (!mounted) {
        return;
      }

      final refreshFailed = provider.error != null;

      Navigator.of(context).pop(true);

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            refreshFailed
                ? 'Course dihapus, tetapi daftar gagal dimuat ulang.'
                : 'Course ${_course.code} berhasil dihapus.',
          ),
          backgroundColor:
              refreshFailed ? Colors.orange.shade700 : Colors.green.shade700,
        ),
      );
    } catch (error) {
      if (!mounted) {
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

  @override
  Widget build(BuildContext context) {
    final favoriteState = context.watch<CourseState>();
    final isFavorite = favoriteState.isFavorite(_course.code);
    final statusColor = _statusColor(_course.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Course'),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Hapus dari Favorites' : 'Tambah ke Favorites',
            onPressed: () {
              context.read<CourseState>().toggleFavorite(_course.code);
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
          IconButton(
            tooltip: 'Edit Course',
            onPressed: _editCourse,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Hapus Course',
            onPressed: _deleteCourse,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF5FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '2415051004 • Kadek Martini Aristianti',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23496D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kode Course',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _course.code,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Judul Course',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _course.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Credits / SKS',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${_course.credits} SKS',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Status Course',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _statusText(_course.status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _editCourse,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Course'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _deleteCourse,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus Course'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
