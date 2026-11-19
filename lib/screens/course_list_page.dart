import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../services/course_ownership_service.dart';
import '../services/profile_service.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';
import '../widgets/role_guard.dart';
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

  late Future<UserProfile?> _profileFuture;

  final TextEditingController _searchController = TextEditingController();
  final CourseOwnershipService _ownershipService = CourseOwnershipService();

  Set<int> _ownedCourseIds = {};
  bool _isLoadingOwnership = true;
  String? _ownershipError;

  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = const [
    {'value': 'all', 'label': 'Semua'},
    {'value': 'planned', 'label': 'Terencana'},
    {'value': 'active', 'label': 'Berjalan'},
    {'value': 'done', 'label': 'Selesai'},
  ];

  bool _canManageCourses(String role) {
    return role == 'instructor' || role == 'admin';
  }

  bool _canManageCourse(String role, Course course) {
    if (role == 'admin') {
      return true;
    }

    if (role == 'instructor' && course.id != null) {
      return _ownedCourseIds.contains(course.id);
    }

    return false;
  }

  @override
  void initState() {
    super.initState();

    _profileFuture = ProfileService().getMyProfile();
    _loadOwnedCourseIds();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOwnedCourseIds() async {
    if (mounted) {
      setState(() {
        _isLoadingOwnership = true;
        _ownershipError = null;
      });
    }

    try {
      final ids = await _ownershipService.getMyOwnedCourseIds();

      if (!mounted) return;

      setState(() {
        _ownedCourseIds = ids;
        _isLoadingOwnership = false;
        _ownershipError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingOwnership = false;
        _ownershipError = error.toString();
      });
    }
  }

  Future<void> _refreshProfile() async {
    final future = ProfileService().getMyProfile();

    setState(() {
      _profileFuture = future;
    });

    await future;
    await _loadOwnedCourseIds();
  }

  Future<void> _openForm(BuildContext context, {Course? course}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => CourseFormPage(course: course)),
    );

    if (result != true || !context.mounted) return;

    final provider = context.read<CourseProvider>();
    await provider.loadCourses();
    await _loadOwnedCourseIds();

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

  Future<void> _openDetail(BuildContext context, Course course) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => CourseDetailPage(course: course)),
    );

    if (result == true && context.mounted) {
      await context.read<CourseProvider>().loadCourses();
      await _loadOwnedCourseIds();
    }
  }

  Future<void> _deleteCourse(
    BuildContext context,
    Course course,
    String role,
  ) async {
    if (!_canManageCourses(role)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamu tidak memiliki akses menghapus kursus.'),
        ),
      );
      return;
    }

    if (course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID kursus tidak ditemukan.')),
      );
      return;
    }

    final courseId = course.id!;

    if (role == 'instructor') {
      try {
        final isOwner = await _ownershipService.isOwnedByCurrentUser(courseId);

        if (!context.mounted) return;

        if (!isOwner) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Akses ditolak. Kamu hanya dapat menghapus kursus milikmu sendiri.',
              ),
              backgroundColor: Colors.red,
            ),
          );

          await _loadOwnedCourseIds();
          return;
        }
      } catch (error) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memeriksa kepemilikan kursus: $error'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
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

    if (role == 'instructor') {
      try {
        final isOwner = await _ownershipService.isOwnedByCurrentUser(courseId);

        if (!context.mounted) return;

        if (!isOwner) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Penghapusan dibatalkan karena kursus bukan milikmu.',
              ),
              backgroundColor: Colors.red,
            ),
          );

          await _loadOwnedCourseIds();
          return;
        }
      } catch (error) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memeriksa kepemilikan kursus: $error'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final provider = context.read<CourseProvider>();
    final favoriteState = context.read<CourseState>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await provider.deleteCourse(courseId);

      String? ownershipWarning;

      if (role == 'instructor' || role == 'admin') {
        try {
          await _ownershipService.removeOwnership(courseId);
        } catch (error) {
          ownershipWarning = error.toString();
        }
      }

      if (favoriteState.isFavorite(course.code)) {
        favoriteState.toggleFavorite(course.code);
      }

      await provider.loadCourses();
      await _loadOwnedCourseIds();

      if (!context.mounted) return;

      final refreshFailed = provider.error != null;

      String message;

      if (ownershipWarning != null) {
        message = 'Kursus berhasil dihapus dari REST API, tetapi catatan kepemilikannya gagal dihapus.';
      } else if (refreshFailed) {
        message = 'Kursus dihapus, tetapi daftar gagal dimuat ulang.';
      } else {
        message = 'Kursus ${course.code} berhasil dihapus.';
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: ownershipWarning != null || refreshFailed
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
      final matchesSearch =
          query.isEmpty ||
          course.title.toLowerCase().contains(query) ||
          course.code.toLowerCase().contains(query) ||
          course.status.toLowerCase().contains(query);

      final matchesStatus =
          _selectedFilter == 'all' || course.status == _selectedFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int _countByStatus(List<Course> courses, String status) {
    if (status == 'all') return courses.length;

    return courses.where((course) => course.status == status).length;
  }

  Widget _buildAdminStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPanel(List<Course> courses) {
    final plannedCount = _countByStatus(courses, 'planned');
    final activeCount = _countByStatus(courses, 'active');
    final completedCount = _countByStatus(courses, 'done');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFDCE8F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: primaryColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panel Administrasi',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ringkasan seluruh katalog kursus.',
                      style: TextStyle(color: mutedColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFF199B60),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 17),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 650 ? 4 : 2;

              final stats = [
                {
                  'title': 'Total Kursus',
                  'value': courses.length,
                  'icon': Icons.menu_book_rounded,
                  'color': const Color(0xFF1976D2),
                  'tint': const Color(0xFFEAF3FF),
                },
                {
                  'title': 'Terencana',
                  'value': plannedCount,
                  'icon': Icons.event_note_rounded,
                  'color': const Color(0xFF64748B),
                  'tint': const Color(0xFFF0F4F8),
                },
                {
                  'title': 'Berjalan',
                  'value': activeCount,
                  'icon': Icons.schedule_rounded,
                  'color': const Color(0xFFD78A24),
                  'tint': const Color(0xFFFFF5E8),
                },
                {
                  'title': 'Selesai',
                  'value': completedCount,
                  'icon': Icons.check_circle_rounded,
                  'color': const Color(0xFF199B60),
                  'tint': const Color(0xFFE9F8EF),
                },
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  childAspectRatio: columns == 2 ? 1.8 : 1.65,
                ),
                itemBuilder: (context, index) {
                  final stat = stats[index];

                  return _buildAdminStatCard(
                    title: stat['title'] as String,
                    value: stat['value'] as int,
                    icon: stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    tint: stat['tint'] as Color,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: mutedColor, size: 15),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Statistik dihitung dari data katalog kursus.',
                  style: TextStyle(color: mutedColor, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(CourseProvider provider) {
    return SizedBox(
      height: 49,
      child: FilledButton.icon(
        onPressed: provider.isSaving ? null : () => _openForm(context),
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withValues(alpha: 0.45),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.add_circle_outline_rounded, size: 21),
        label: const Text(
          'Tambah Kursus',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildHeader(CourseProvider provider, String role) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        const titleSection = Column(
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
              style: TextStyle(fontSize: 12, color: mutedColor),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleSection,
              RoleGuard(
                role: role,
                allowed: const ['instructor', 'admin'],
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildAddButton(provider),
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: titleSection),
            RoleGuard(
              role: role,
              allowed: const ['instructor', 'admin'],
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  _buildAddButton(provider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari nama, kode, atau status kursus...',
        hintStyle: const TextStyle(color: Color(0xFF9AA7B5), fontSize: 12),
        prefixIcon: const Icon(Icons.search_rounded, color: primaryColor),
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
          borderSide: const BorderSide(color: Color(0xFFE8EEF5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE8EEF5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryColor, width: 1.4),
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
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
                      color: selected ? primaryColor : const Color(0xFFF0F4F8),
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
              child: Icon(icon, color: primaryColor, size: 38),
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
    String role,
    bool canManageCourses,
  ) {
    if (role == 'instructor' && _isLoadingOwnership) {
      return const Center(child: CircularProgressIndicator());
    }

    if (role == 'instructor' && _ownershipError != null) {
      return ErrorView(
        message: 'Gagal memuat kepemilikan kursus: $_ownershipError',
        onRetry: _loadOwnedCourseIds,
      );
    }

    if (provider.isLoading && provider.courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.courses.isEmpty) {
      return ErrorView(message: provider.error!, onRetry: provider.loadCourses);
    }

    if (provider.courses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Belum Ada Kursus',
        message: canManageCourses
            ? 'Tambahkan kursus pertama untuk memulai.'
            : 'Belum ada kursus yang tersedia.',
        onAction: canManageCourses ? () => _openForm(context) : null,
        actionLabel: canManageCourses ? 'Tambah Kursus' : null,
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
        if (provider.isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.loadCourses,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 4, bottom: 25),
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = courses[index];
                final canManageThisCourse = _canManageCourse(role, course);

                return InteractiveCourseCard(
                  course: course,
                  showFavoriteButton: true,
                  isFavorite: favoriteState.isFavorite(course.code),
                  onToggleFavorite: () {
                    favoriteState.toggleFavorite(course.code);
                  },
                  onTap: () => _openDetail(context, course),
                  onEdit: canManageThisCourse
                      ? () => _openForm(context, course: course)
                      : null,
                  onDelete: canManageThisCourse
                      ? () => _deleteCourse(context, course, role)
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileLoading() {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileError() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Kursus'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 42,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gagal Memuat Profil Pengguna',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Role pengguna diperlukan untuk menentukan hak akses.',
                textAlign: TextAlign.center,
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _refreshProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Muat Ulang Profil'),
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
          return _buildProfileLoading();
        }

        if (profileSnapshot.hasError || profileSnapshot.data == null) {
          return _buildProfileError();
        }

        final profile = profileSnapshot.data!;
        final role = profile.role;
        final canManageCourses = _canManageCourses(role);

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
                Icon(Icons.school_rounded, color: primaryColor, size: 25),
                SizedBox(width: 10),
                Text(
                  'Kursus',
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
                onPressed: provider.isLoading ? null : provider.loadCourses,
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
                          RoleGuard(
                            role: role,
                            allowed: const ['admin'],
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 17),
                              child: _buildAdminPanel(allCourses),
                            ),
                          ),
                          _buildHeader(provider, role),
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
                              role,
                              canManageCourses,
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
