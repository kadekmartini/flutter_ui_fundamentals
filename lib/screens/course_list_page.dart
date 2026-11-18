
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';
import 'course_detail_page.dart';
import 'course_form_page.dart';
import 'home_page.dart' show StudentIdentityBanner;

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF26364A);
  static const Color mutedColor = Color(0xFF718096);

  final TextEditingController _searchController =
      TextEditingController();

  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = const [
    {'value': 'all', 'label': 'Semua'},
    {'value': 'planned', 'label': 'Terencana'},
    {'value': 'active', 'label': 'Berjalan'},
    {'value': 'done', 'label': 'Selesai'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm(
    BuildContext context, {
    Course? course,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CourseFormPage(course: course),
      ),
    );

    if (result != true || !context.mounted) return;

    final provider = context.read<CourseProvider>();
    await provider.loadCourses();

    if (!context.mounted) return;

    final refreshFailed = provider.error != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          refreshFailed
              ? 'Data tersimpan, tetapi daftar gagal dimuat ulang.'
              : course == null
                  ? 'Kursus berhasil ditambahkan.'
                  : 'Kursus berhasil diperbarui.',
        ),
        backgroundColor: refreshFailed
            ? Colors.orange.shade700
            : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
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
          content: Text('ID kursus tidak ditemukan.'),
        ),
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
            size: 36,
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

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<CourseProvider>();
    final favoriteState = context.read<CourseState>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.deleteCourse(course.id!);

      if (favoriteState.isFavorite(course.code)) {
        favoriteState.toggleFavorite(course.code);
      }

      await provider.loadCourses();

      if (!context.mounted) return;

      final refreshFailed = provider.error != null;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            refreshFailed
                ? 'Kursus dihapus, tetapi daftar gagal dimuat ulang.'
                : 'Kursus ${course.code} berhasil dihapus.',
          ),
          backgroundColor: refreshFailed
              ? Colors.orange.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus kursus: $error'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<Course> _filterCourses(List<Course> courses) {
    final query = _searchController.text.trim().toLowerCase();

    return courses.where((course) {
      final matchesSearch = query.isEmpty ||
          course.title.toLowerCase().contains(query) ||
          course.code.toLowerCase().contains(query) ||
          course.status.toLowerCase().contains(query);

      final matchesStatus =
          _selectedFilter == 'all' ||
          course.status == _selectedFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int _countByStatus(List<Course> courses, String status) {
    if (status == 'all') return courses.length;

    return courses
        .where((course) => course.status == status)
        .length;
  }

  Widget _buildHeader(CourseProvider provider) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 14,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Kursus',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Kelola seluruh materi pembelajaran.',
              style: TextStyle(
                fontSize: 12,
                color: mutedColor,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: provider.isSaving
              ? null
              : () => _openForm(context),
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'Tambah Kursus',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari nama, kode, atau status kursus...',
        hintStyle: const TextStyle(
          color: Color(0xFF9AA7B5),
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: primaryColor,
        ),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE8EEF5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFE8EEF5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<Course> courses) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final value = filter['value']!;
          final label = filter['label']!;
          final selected = _selectedFilter == value;
          final count = _countByStatus(courses, value);

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: ChoiceChip(
              selected: selected,
              showCheckmark: false,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = value;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFE5F0FF),
              side: BorderSide(
                color: selected
                    ? primaryColor.withValues(alpha: 0.35)
                    : const Color(0xFFE8EEF5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selected ? primaryColor : mutedColor,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? primaryColor
                          : const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: selected ? Colors.white : mutedColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEAF3FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: mutedColor,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCourseContent(
    BuildContext context,
    CourseProvider provider,
    CourseState favoriteState,
    List<Course> courses,
  ) {
    if (provider.isLoading && provider.courses.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null && provider.courses.isEmpty) {
      return ErrorView(
        message: provider.error!,
        onRetry: provider.loadCourses,
      );
    }

    if (provider.courses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Belum Ada Kursus',
        message: 'Tambahkan kursus pertama untuk memulai.',
        onAction: () => _openForm(context),
        actionLabel: 'Tambah Kursus',
      );
    }

    if (courses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Kursus Tidak Ditemukan',
        message: 'Coba gunakan kata kunci atau filter yang berbeda.',
        onAction: () {
          _searchController.clear();
          setState(() {
            _selectedFilter = 'all';
          });
        },
        actionLabel: 'Atur Ulang Filter',
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
              padding: const EdgeInsets.only(
                top: 4,
                bottom: 25,
              ),
              itemCount: courses.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = courses[index];

                return InteractiveCourseCard(
                  course: course,
                  showFavoriteButton: true,
                  isFavorite: favoriteState.isFavorite(course.code),
                  onToggleFavorite: () {
                    favoriteState.toggleFavorite(course.code);
                  },
                  onTap: () => _openDetail(context, course),
                  onEdit: () => _openForm(
                    context,
                    course: course,
                  ),
                  onDelete: () => _deleteCourse(
                    context,
                    course,
                  ),
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

    final allCourses = provider.courses;
    final filteredCourses = _filterCourses(allCourses);

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
              Icons.school_rounded,
              color: primaryColor,
              size: 25,
            ),
            SizedBox(width: 10),
            Text(
              'Manajemen Kursus',
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
            tooltip: 'Muat Ulang Kursus',
            onPressed: provider.isLoading
                ? null
                : provider.loadCourses,
            icon: const Icon(
              Icons.refresh_rounded,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth < 600 ? 17.0 : 28.0;

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
                      _buildHeader(provider),
                      const SizedBox(height: 15),
                      const StudentIdentityBanner(),
                      const SizedBox(height: 17),
                      _buildSearchField(),
                      const SizedBox(height: 15),
                      _buildFilterChips(allCourses),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Kursus Tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF3FF),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              '${filteredCourses.length} kursus',
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Expanded(
                        child: _buildCourseContent(
                          context,
                          provider,
                          favoriteState,
                          filteredCourses,
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
