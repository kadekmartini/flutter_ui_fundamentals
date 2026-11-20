import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../services/profile_service.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';
import 'course_detail_page.dart';
import 'course_form_page.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF26364A);
  static const Color mutedColor = Color(0xFF718096);

  late Future<UserProfile?> _profileFuture;

  bool _isProcessing = false;

  bool _canManageCourses(String role) {
    return role == 'instructor' || role == 'admin';
  }

  bool _isOwnedByCurrentUser(Course course, UserProfile profile) {
    return _canManageCourses(profile.role) && course.isOwnedBy(profile.id);
  }

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
  }

  void _showMessage(String message, {Color? backgroundColor}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshProfile() async {
    final future = ProfileService().getMyProfile();

    setState(() {
      _profileFuture = future;
    });

    try {
      await future;
    } catch (_) {}
  }

  Future<void> _refresh() async {
    await context.read<CourseProvider>().loadCourses();
  }

  Future<void> _openAddForm() async {
    if (_isProcessing) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const CourseFormPage()),
    );

    if (result != true || !mounted) return;

    await _refresh();

    if (!mounted) return;

    final provider = context.read<CourseProvider>();

    _showMessage(
      provider.error == null
          ? 'Kursus berhasil ditambahkan ke Kursus Saya.'
          : 'Kursus ditambahkan, tetapi daftar gagal dimuat ulang.',
      backgroundColor: provider.error == null
          ? Colors.green.shade700
          : Colors.orange.shade700,
    );
  }

  Future<bool> _checkOwnership(Course course) async {
    final profile = await ProfileService().getMyProfile();

    if (profile == null) return false;

    return _isOwnedByCurrentUser(course, profile);
  }

  Future<void> _openEditForm(Course course) async {
    if (_isProcessing) return;

    if (course.id == null) {
      _showMessage(
        'ID kursus tidak ditemukan.',
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    try {
      final isOwner = await _checkOwnership(course);

      if (!mounted) return;

      if (!isOwner) {
        _showMessage(
          'Kamu hanya dapat mengedit kursus milikmu sendiri.',
          backgroundColor: Colors.red.shade700,
        );
        await _refresh();
        return;
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal memeriksa kepemilikan kursus: $error',
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    if (!mounted) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => CourseFormPage(course: course)),
    );

    if (result != true || !mounted) return;

    await _refresh();

    if (!mounted) return;

    final provider = context.read<CourseProvider>();

    _showMessage(
      provider.error == null
          ? 'Kursus berhasil diperbarui.'
          : 'Perubahan tersimpan, tetapi daftar gagal dimuat ulang.',
      backgroundColor: provider.error == null
          ? Colors.green.shade700
          : Colors.orange.shade700,
    );
  }

  Future<void> _deleteCourse(Course course) async {
    if (_isProcessing) return;

    if (course.id == null) {
      _showMessage(
        'ID kursus tidak ditemukan.',
        backgroundColor: Colors.red.shade700,
      );
      return;
    }

    final courseId = course.id!;

    try {
      final isOwner = await _checkOwnership(course);

      if (!mounted) return;

      if (!isOwner) {
        _showMessage(
          'Kamu hanya dapat menghapus kursus milikmu sendiri.',
          backgroundColor: Colors.red.shade700,
        );
        await _refresh();
        return;
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal memeriksa kepemilikan kursus: $error',
        backgroundColor: Colors.red.shade700,
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
            size: 38,
          ),
          title: const Text(
            'Hapus Kursus?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus "${course.title}" (${course.code})?',
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
      _isProcessing = true;
    });

    final provider = context.read<CourseProvider>();
    final favoriteState = context.read<CourseState>();

    try {
      final isOwner = await _checkOwnership(course);

      if (!isOwner) {
        throw StateError('Kursus bukan milik akun yang sedang login.');
      }

      await provider.deleteCourse(courseId);

      if (favoriteState.isFavorite(course.code)) {
        favoriteState.toggleFavorite(course.code);
      }

      await _refresh();

      if (!mounted) return;

      _showMessage(
        provider.error == null
            ? 'Kursus ${course.code} berhasil dihapus.'
            : 'Kursus dihapus, tetapi daftar gagal dimuat ulang.',
        backgroundColor: provider.error == null
            ? Colors.green.shade700
            : Colors.orange.shade700,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Gagal menghapus kursus: $error',
        backgroundColor: Colors.red.shade700,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _openDetail(Course course) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => CourseDetailPage(course: course)),
    );

    if (result == true && mounted) {
      await _refresh();
    }
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: _isProcessing ? null : _openAddForm,
        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
        label: const Text(
          'Tambah Kursus',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool canManage) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 450;

        const titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kursus Saya',
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Kelola kursus yang kamu miliki.',
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
          ],
        );

        if (!canManage) {
          return titleSection;
        }

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleSection,
              const SizedBox(height: 15),
              _buildAddButton(),
            ],
          );
        }

        return Row(
          children: [
            const Expanded(child: titleSection),
            const SizedBox(width: 15),
            _buildAddButton(),
          ],
        );
      },
    );
  }

  Widget _buildSummary(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE3ECF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Kursus Milik Saya',
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count Kursus',
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool canManage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFEAF3FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: primaryColor,
                size: 42,
              ),
            ),
            const SizedBox(height: 17),
            const Text(
              'Belum Ada Kursus Milikmu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              canManage
                  ? 'Kursus yang kamu tambahkan akan muncul di halaman ini.'
                  : 'Belum ada kursus yang tercatat sebagai milikmu.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: mutedColor,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (canManage) ...[const SizedBox(height: 18), _buildAddButton()],
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList(
    List<Course> courses,
    CourseProvider provider,
    CourseState favoriteState,
  ) {
    return Column(
      children: [
        if (provider.isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 25),
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = courses[index];

                return InteractiveCourseCard(
                  course: course,
                  showFavoriteButton: true,
                  isFavorite: favoriteState.isFavorite(course.code),
                  onToggleFavorite: () {
                    favoriteState.toggleFavorite(course.code);
                  },
                  onTap: () => _openDetail(course),
                  onEdit: () => _openEditForm(course),
                  onDelete: () => _deleteCourse(course),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileError() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Kursus Saya'),
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
    final provider = context.watch<CourseProvider>();
    final favoriteState = context.watch<CourseState>();

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (profileSnapshot.hasError || profileSnapshot.data == null) {
          return _buildProfileError();
        }

        final profile = profileSnapshot.data!;
        final canManage = _canManageCourses(profile.role);

        final myCourses = provider.courses
            .where((course) => course.isOwnedBy(profile.id))
            .toList();

        if (provider.isLoading && provider.courses.isEmpty) {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null && provider.courses.isEmpty) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ErrorView(message: provider.error!, onRetry: _refresh),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Row(
              children: [
                Icon(
                  Icons.folder_special_rounded,
                  color: primaryColor,
                  size: 25,
                ),
                SizedBox(width: 10),
                Text(
                  'Kursus Saya',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Muat Ulang',
                onPressed: provider.isLoading || _isProcessing
                    ? null
                    : _refresh,
                icon: const Icon(Icons.refresh_rounded, color: textColor),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 600
                    ? 17.0
                    : 28.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1050),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(canManage),
                          const SizedBox(height: 18),
                          Expanded(
                            child: Column(
                              children: [
                                _buildSummary(myCourses.length),
                                const SizedBox(height: 18),
                                Expanded(
                                  child: myCourses.isEmpty
                                      ? _buildEmptyState(canManage)
                                      : _buildCourseList(
                                          myCourses,
                                          provider,
                                          favoriteState,
                                        ),
                                ),
                              ],
                            ),
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
      },
    );
  }
}
