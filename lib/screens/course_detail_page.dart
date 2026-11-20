import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../services/profile_service.dart';
import 'course_form_page.dart';
import 'home_page.dart' show StudentIdentityBanner;

enum _DetailAction { edit, delete }

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF26364A);
  static const Color mutedColor = Color(0xFF718096);
  static const Color favoriteColor = Color(0xFFE53950);

  late Course _course;
  late Future<UserProfile?> _profileFuture;
  late Future<bool> _managementAccessFuture;

  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    _course = widget.course;
    _profileFuture = ProfileService().getMyProfile();
    _managementAccessFuture = _loadManagementAccess();
  }

  Future<bool> _loadManagementAccess() async {
    final profile = await _profileFuture;

    if (profile == null) {
      return false;
    }

    if (profile.role == 'admin') {
      return true;
    }

    if (profile.role == 'instructor') {
      return _course.isOwnedBy(profile.id);
    }

    return false;
  }

  Future<bool> _hasManagementAccess() async {
    final profile = await ProfileService().getMyProfile();

    if (profile == null) {
      return false;
    }

    if (profile.role == 'admin') {
      return true;
    }

    if (profile.role == 'instructor') {
      return _course.isOwnedBy(profile.id);
    }

    return false;
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = ProfileService().getMyProfile();
      _managementAccessFuture = _loadManagementAccess();
    });
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

  void _showMessage(String message, {Color? color}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildFavoriteButton(bool isFavorite) {
    return IconButton(
      tooltip: isFavorite ? 'Hapus dari Favorit' : 'Tambahkan ke Favorit',
      onPressed: _isDeleting
          ? null
          : () {
              context.read<CourseState>().toggleFavorite(_course.code);
            },
      icon: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: favoriteColor,
        size: 25,
      ),
    );
  }

  Future<void> _editCourse() async {
    try {
      final hasAccess = await _hasManagementAccess();

      if (!mounted) return;

      if (!hasAccess) {
        _showMessage(
          'Akses ditolak. Kamu hanya dapat mengedit kursus milikmu sendiri.',
          color: Colors.red.shade700,
        );
        return;
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal memeriksa hak akses: $error',
        color: Colors.red.shade700,
      );
      return;
    }

    if (!mounted) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => CourseFormPage(course: _course)),
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

    setState(() {
      if (updatedCourses.isNotEmpty) {
        _course = updatedCourses.first;
      }

      _managementAccessFuture = _loadManagementAccess();
    });

    _showMessage('Kursus berhasil diperbarui.');
  }

  Future<void> _deleteCourse() async {
    try {
      final hasAccess = await _hasManagementAccess();

      if (!mounted) return;

      if (!hasAccess) {
        _showMessage(
          'Akses ditolak. Kamu hanya dapat menghapus kursus milikmu sendiri.',
          color: Colors.red.shade700,
        );
        return;
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal memeriksa hak akses: $error',
        color: Colors.red.shade700,
      );
      return;
    }

    if (!mounted) return;

    if (_course.id == null) {
      _showMessage('ID kursus tidak ditemukan.', color: Colors.red.shade700);
      return;
    }

    final courseId = _course.id!;

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
            style: TextStyle(fontWeight: FontWeight.w800),
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

    try {
      final hasAccess = await _hasManagementAccess();

      if (!mounted) return;

      if (!hasAccess) {
        _showMessage(
          'Penghapusan dibatalkan karena kamu bukan pemilik kursus.',
          color: Colors.red.shade700,
        );
        return;
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal memeriksa kepemilikan kursus: $error',
        color: Colors.red.shade700,
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    final provider = context.read<CourseProvider>();
    final favoriteState = context.read<CourseState>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.deleteCourse(courseId);

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

  void _handleAction(_DetailAction action, bool canManageThisCourse) {
    if (!canManageThisCourse) return;

    switch (action) {
      case _DetailAction.edit:
        _editCourse();
        break;
      case _DetailAction.delete:
        _deleteCourse();
        break;
    }
  }

  Widget _buildActionMenu(bool canManageThisCourse) {
    if (!canManageThisCourse) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<_DetailAction>(
      tooltip: 'Pilihan Kursus',
      enabled: !_isDeleting,
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (action) {
        _handleAction(action, canManageThisCourse);
      },
      icon: const Icon(Icons.more_vert_rounded, color: mutedColor, size: 23),
      itemBuilder: (context) {
        return [
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
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  Widget _buildCourseHeader() {
    final statusColor = _statusColor(_course.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF1255A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
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
          const Icon(Icons.menu_book_rounded, color: Colors.white, size: 38),
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
        border: Border.all(color: const Color(0xFFE8EEF5)),
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
          child: Icon(icon, color: primaryColor, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: mutedColor, fontSize: 11),
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

  Widget _buildLoadingPage() {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileErrorPage() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Kursus'),
        backgroundColor: backgroundColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: Colors.redAccent,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gagal Memuat Profil Pengguna',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _refreshProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Muat Ulang'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessErrorPage() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Kursus'),
        backgroundColor: backgroundColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: Colors.redAccent,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gagal Memeriksa Kepemilikan Kursus',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Periksa koneksi dan coba muat ulang halaman.',
                textAlign: TextAlign.center,
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _refreshProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState != ConnectionState.done) {
          return _buildLoadingPage();
        }

        if (profileSnapshot.hasError || profileSnapshot.data == null) {
          return _buildProfileErrorPage();
        }

        return FutureBuilder<bool>(
          future: _managementAccessFuture,
          builder: (context, accessSnapshot) {
            if (accessSnapshot.connectionState != ConnectionState.done) {
              return _buildLoadingPage();
            }

            if (accessSnapshot.hasError) {
              return _buildAccessErrorPage();
            }

            final canManageThisCourse = accessSnapshot.data ?? false;

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
                  _buildFavoriteButton(isFavorite),
                  _buildActionMenu(canManageThisCourse),
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
                                  : () {
                                      Navigator.of(context).pop();
                                    },
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
                            const Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
