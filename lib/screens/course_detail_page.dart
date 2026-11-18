
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import 'course_form_page.dart';
import 'home_page.dart' show StudentIdentityBanner;

enum _DetailAction {
  favorite,
  edit,
  delete,
}

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
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF26364A);
  static const Color mutedColor = Color(0xFF718096);

  late Course _course;
  bool _isDeleting = false;

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
        return const Color(0xFF16A36A);
      case 'active':
        return const Color(0xFFE39428);
      default:
        return const Color(0xFF64748B);
    }
  }

  void _showMessage(
    String message, {
    Color? color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _editCourse() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CourseFormPage(course: _course),
      ),
    );

    if (result != true || !mounted) return;

    final provider = context.read<CourseProvider>();

    await provider.loadCourses();

    if (!mounted) return;

    if (provider.error != null) {
      _showMessage(
        'Perubahan tersimpan, tetapi detail gagal dimuat ulang.',
        color: Colors.orange.shade700,
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

    _showMessage('Kursus berhasil diperbarui.');
  }

  Future<void> _deleteCourse() async {
    if (_course.id == null) {
      _showMessage(
        'ID kursus tidak ditemukan.',
        color: Colors.red.shade700,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(
            Icons.delete_outline_rounded,
            color: Colors.red.shade600,
            size: 40,
          ),
          title: const Text(
            'Hapus Kursus?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus "${_course.title}" (${_course.code})?',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    final provider = context.read<CourseProvider>();
    final favoriteState = context.read<CourseState>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.deleteCourse(_course.id!);

      if (favoriteState.isFavorite(_course.code)) {
        favoriteState.toggleFavorite(_course.code);
      }

      await provider.loadCourses();

      if (!mounted) return;

      final refreshFailed = provider.error != null;
      final message = refreshFailed
          ? 'Kursus dihapus, tetapi daftar gagal dimuat ulang.'
          : 'Kursus ${_course.code} berhasil dihapus.';

      Navigator.of(context).pop(true);

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: refreshFailed
              ? Colors.orange.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
      });

      _showMessage(
        'Gagal menghapus kursus: $error',
        color: Colors.red.shade700,
      );
    }
  }

  void _handleAction(_DetailAction action) {
    switch (action) {
      case _DetailAction.favorite:
        context.read<CourseState>().toggleFavorite(_course.code);
        break;
      case _DetailAction.edit:
        _editCourse();
        break;
      case _DetailAction.delete:
        _deleteCourse();
        break;
    }
  }

  Widget _buildActionMenu(bool isFavorite) {
    return PopupMenuButton<_DetailAction>(
      tooltip: 'Pilihan Kursus',
      enabled: !_isDeleting,
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: _handleAction,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _DetailAction.favorite,
          child: Row(
            children: [
              Icon(
                isFavorite
                    ? Icons.favorite_border_rounded
                    : Icons.favorite_rounded,
                color: Colors.red.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                isFavorite
                    ? 'Hapus dari Favorit'
                    : 'Tambahkan ke Favorit',
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: _DetailAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 12),
              Text('Edit Kursus'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _DetailAction.delete,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Hapus Kursus',
                style: TextStyle(
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseHeader() {
    final statusColor = _statusColor(_course.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1976D2),
            Color(0xFF1255A0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'INFORMASI KURSUS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(height: 15),
          Text(
            _course.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 9,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _course.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_course.credits} SKS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusText(_course.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE8EEF5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Kursus',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.tag_rounded,
            title: 'Kode Kursus',
            value: _course.code,
          ),
          const Divider(height: 27),
          _buildInfoRow(
            icon: Icons.menu_book_outlined,
            title: 'Nama Kursus',
            value: _course.title,
          ),
          const Divider(height: 27),
          _buildInfoRow(
            icon: Icons.school_outlined,
            title: 'Jumlah SKS',
            value: '${_course.credits} SKS',
          ),
          const Divider(height: 27),
          _buildInfoRow(
            icon: Icons.flag_outlined,
            title: 'Status Kursus',
            value: _statusText(_course.status),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 21,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: mutedColor,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteState = context.watch<CourseState>();
    final isFavorite = favoriteState.isFavorite(_course.code);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Detail Kursus',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          _buildActionMenu(isFavorite),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StudentIdentityBanner(),
                  const SizedBox(height: 20),
                  _buildCourseHeader(),
                  const SizedBox(height: 18),
                  _buildInformationCard(),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Kembali ke Daftar Kursus'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(
                          color: Color(0xFFB8D4F2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (_isDeleting)
                    const Center(
                      child: CircularProgressIndicator(),
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
