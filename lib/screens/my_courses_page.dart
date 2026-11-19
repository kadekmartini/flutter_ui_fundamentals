import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../services/course_ownership_service.dart';
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

  final CourseOwnershipService _ownershipService = CourseOwnershipService();

  late Future<Set<int>> _ownedCourseIdsFuture;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _ownedCourseIdsFuture = _ownershipService.getMyOwnedCourseIds();
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

  Future<void> _refresh() async {
    final provider = context.read<CourseProvider>();

    await provider.loadCourses();

    if (!mounted) return;

    final future = _ownershipService.getMyOwnedCourseIds();

    setState(() {
      _ownedCourseIdsFuture = future;
    });

    try {
      await future;
    } catch (_) {}
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

  Future<bool> _checkOwnership(int courseId) async {
    try {
      return await _ownershipService.isOwnedByCurrentUser(courseId);
    } catch (error) {
      _showMessage(
        'Gagal memeriksa kepemilikan kursus: $error',
        backgroundColor: Colors.red.shade700,
      );
      return false;
    }
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

    final isOwner = await _checkOwnership(course.id!);

    if (!mounted) return;

    if (!isOwner) {
      _showMessage(
        'Kamu hanya dapat mengedit kursus milikmu sendiri.',
        backgroundColor: Colors.red.shade700,
      );
      await _refresh();
      return;
    }

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

    final isOwner = await _checkOwnership(courseId);

    if (!mounted) return;

    if (!isOwner) {
      _showMessage(
        'Kamu hanya dapat menghapus kursus milikmu sendiri.',
        backgroundColor: Colors.red.shade700,
      );
      await _refresh();
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
      final ownershipConfirmed = await _ownershipService.isOwnedByCurrentUser(
        courseId,
      );

      if (!ownershipConfirmed) {
        throw Exception('Kursus bukan milik akun yang sedang login.');
      }

      await provider.deleteCourse(courseId);

      String? ownershipError;

      try {
        await _ownershipService.removeOwnership(courseId);
      } catch (error) {
        ownershipError = error.toString();
      }

      if (favoriteState.isFavorite(course.code)) {
        favoriteState.toggleFavorite(course.code);
      }

      await _refresh();

      if (!mounted) return;

      if (ownershipError != null) {
        _showMessage(
          'Kursus berhasil dihapus, tetapi catatan kepemilikan gagal dihapus.',
          backgroundColor: Colors.orange.shade700,
        );
      } else if (provider.error != null) {
        _showMessage(
          'Kursus dihapus, tetapi daftar gagal dimuat ulang.',
          backgroundColor: Colors.orange.shade700,
        );
      } else {
        _showMessage('Kursus ${course.code} berhasil dihapus.');
      }
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

  Widget _buildHeader() {
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

  Widget _buildEmptyState() {
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
            const Text(
              'Kursus yang kamu tambahkan akan muncul di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedColor, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 18),
            _buildAddButton(),
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final favoriteState = context.watch<CourseState>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.folder_special_rounded, color: primaryColor, size: 25),
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
            onPressed: provider.isLoading || _isProcessing ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded, color: textColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 600 ? 17.0 : 28.0;

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
                      _buildHeader(),
                      const SizedBox(height: 18),
                      Expanded(
                        child: FutureBuilder<Set<int>>(
                          future: _ownedCourseIdsFuture,
                          builder: (context, ownershipSnapshot) {
                            if (ownershipSnapshot.connectionState !=
                                ConnectionState.done) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (ownershipSnapshot.hasError) {
                              return ErrorView(
                                message:
                                    'Gagal memuat kepemilikan kursus: ${ownershipSnapshot.error}',
                                onRetry: _refresh,
                              );
                            }

                            if (provider.isLoading &&
                                provider.courses.isEmpty) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (provider.error != null &&
                                provider.courses.isEmpty) {
                              return ErrorView(
                                message: provider.error!,
                                onRetry: _refresh,
                              );
                            }

                            final ownedIds = ownershipSnapshot.data!;

                            final myCourses = provider.courses.where((course) {
                              return course.id != null &&
                                  ownedIds.contains(course.id);
                            }).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSummary(myCourses.length),
                                const SizedBox(height: 18),
                                Expanded(
                                  child: myCourses.isEmpty
                                      ? _buildEmptyState()
                                      : _buildCourseList(
                                          myCourses,
                                          provider,
                                          favoriteState,
                                        ),
                                ),
                              ],
                            );
                          },
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
  }
}
