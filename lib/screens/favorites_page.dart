import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../services/profile_service.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';
import 'course_detail_page.dart';
import 'home_page.dart' show StudentIdentityBanner;

class _AdminFavoritesData {
  final List<UserProfile> profiles;
  final List<Map<String, dynamic>> favorites;

  const _AdminFavoritesData({required this.profiles, required this.favorites});
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF26364A);
  static const Color mutedColor = Color(0xFF718096);
  static const Color favoriteColor = Color(0xFFE53950);

  late Future<UserProfile?> _profileFuture;

  Future<_AdminFavoritesData>? _adminDataFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
  }

  Future<_AdminFavoritesData> _loadAdminData() async {
    final profiles = await ProfileService().getAllProfilesForAdmin();

    final response = await Supabase.instance.client
        .from('course_favorites')
        .select('user_id, course_code, created_at')
        .order('created_at', ascending: false);

    final favorites = response
        .map<Map<String, dynamic>>((row) => Map<String, dynamic>.from(row))
        .toList();

    return _AdminFavoritesData(profiles: profiles, favorites: favorites);
  }

  Future<void> _refreshAdminData() async {
    final future = _loadAdminData();

    setState(() {
      _adminDataFuture = future;
    });

    try {
      await future;
    } catch (_) {}
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = ProfileService().getMyProfile();
      _adminDataFuture = null;
    });

    await _profileFuture;
  }

  Future<void> _refreshPersonalFavorites() async {
    await context.read<CourseProvider>().loadCourses();

    if (!mounted) return;

    await context.read<CourseState>().loadFavorites(forceRefresh: true);
  }

  Future<void> _openDetail(BuildContext context, Course course) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => CourseDetailPage(course: course)),
    );

    if (result == true && context.mounted) {
      await context.read<CourseProvider>().loadCourses();
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'student':
        return 'Student';
      case 'instructor':
        return 'Instructor';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }

  Widget _buildHeader(int totalFavorites) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF1255A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'KURSUS TERSIMPAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Kursus Favorit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Kumpulan kursus pilihan yang kamu simpan.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard(int totalFavorites) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: favoriteColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jumlah Kursus Favorit',
                  style: TextStyle(
                    fontSize: 11,
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalFavorites kursus tersimpan',
                  style: const TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              totalFavorites.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: favoriteColor,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: favoriteColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Kursus Favorit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simpan kursus yang kamu sukai dengan menekan ikon Love pada kartu kursus.',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedColor, fontSize: 12, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalContent(
    BuildContext context,
    CourseProvider provider,
    CourseState favoriteState,
    List<Course> favoriteCourses,
  ) {
    if (favoriteState.isLoading && !favoriteState.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favoriteState.error != null && !favoriteState.hasLoaded) {
      return ErrorView(
        message: 'Gagal memuat Favorit: ${favoriteState.error}',
        onRetry: () {
          favoriteState.loadFavorites(forceRefresh: true);
        },
      );
    }

    if (provider.isLoading && provider.courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.courses.isEmpty) {
      return ErrorView(message: provider.error!, onRetry: provider.loadCourses);
    }

    if (favoriteCourses.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (provider.isLoading || favoriteState.isLoading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshPersonalFavorites,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 3, bottom: 25),
              itemCount: favoriteCourses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = favoriteCourses[index];

                return InteractiveCourseCard(
                  course: course,
                  onTap: () => _openDetail(context, course),
                  showFavoriteButton: true,
                  isFavorite: favoriteState.isFavorite(course.code),
                  onToggleFavorite: () {
                    favoriteState.toggleFavorite(course.code);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalFavorites(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final favoriteState = context.watch<CourseState>();

    final favoriteCourses = provider.courses.where((course) {
      return favoriteState.isFavorite(course.code);
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.favorite_rounded, color: favoriteColor, size: 25),
            SizedBox(width: 10),
            Text(
              'Favorit',
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
            tooltip: 'Muat Ulang Favorit',
            onPressed: provider.isLoading || favoriteState.isLoading
                ? null
                : _refreshPersonalFavorites,
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
                    12,
                    horizontalPadding,
                    12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(favoriteCourses.length),
                      const SizedBox(height: 15),
                      const StudentIdentityBanner(),
                      const SizedBox(height: 17),
                      _buildCountCard(favoriteCourses.length),
                      const SizedBox(height: 22),
                      const Text(
                        'Daftar Kursus Favorit',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Kursus yang telah kamu tambahkan ke favorit.',
                        style: TextStyle(fontSize: 12, color: mutedColor),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: _buildPersonalContent(
                          context,
                          provider,
                          favoriteState,
                          favoriteCourses,
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

  Widget _buildAdminUserCard({
    required UserProfile profile,
    required List<String> courseCodes,
    required List<Course> courses,
  }) {
    final displayName = profile.name.trim().isEmpty
        ? profile.email
        : profile.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: primaryColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: mutedColor, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _roleLabel(profile.role),
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${courseCodes.length} Favorit',
                    style: const TextStyle(color: mutedColor, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          if (courseCodes.isEmpty)
            const Text(
              'Belum ada kursus Favorit.',
              style: TextStyle(color: mutedColor, fontSize: 11),
            )
          else
            ...courseCodes.map((code) {
              Course? matchedCourse;

              for (final course in courses) {
                if (course.code == code) {
                  matchedCourse = course;
                  break;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: favoriteColor,
                      size: 20,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            matchedCourse?.title ??
                                'Kursus tidak ditemukan di katalog',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            matchedCourse == null
                                ? code
                                : '$code • ${matchedCourse.credits} SKS',
                            style: const TextStyle(
                              color: mutedColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAdminFavorites(BuildContext context, List<Course> courses) {
    _adminDataFuture ??= _loadAdminData();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.admin_panel_settings_rounded,
              color: primaryColor,
              size: 25,
            ),
            SizedBox(width: 10),
            Text(
              'Pemantauan Favorit',
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
            tooltip: 'Muat Ulang Favorit',
            onPressed: _refreshAdminData,
            icon: const Icon(Icons.refresh_rounded, color: textColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<_AdminFavoritesData>(
          future: _adminDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null) {
              return Center(
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
                        'Gagal Memuat Data Favorit',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: mutedColor, fontSize: 11),
                      ),
                      const SizedBox(height: 15),
                      FilledButton.icon(
                        onPressed: _refreshAdminData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final favoritesByUser = <String, List<String>>{};

            for (final favorite in data.favorites) {
              final userId = favorite['user_id'] as String?;
              final courseCode = favorite['course_code'] as String?;

              if (userId == null || courseCode == null) {
                continue;
              }

              favoritesByUser.putIfAbsent(userId, () => []);
              favoritesByUser[userId]!.add(courseCode);
            }

            for (final codes in favoritesByUser.values) {
              codes.sort();
            }

            final totalUsersWithFavorites = favoritesByUser.values
                .where((codes) => codes.isNotEmpty)
                .length;

            return RefreshIndicator(
              onRefresh: _refreshAdminData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                children: [
                  _buildHeader(data.favorites.length),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAdminSummaryCard(
                          title: 'Total Favorit',
                          value: data.favorites.length,
                          icon: Icons.favorite_rounded,
                          color: favoriteColor,
                          tint: const Color(0xFFFFF0F2),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: _buildAdminSummaryCard(
                          title: 'Pengguna Favorit',
                          value: totalUsersWithFavorites,
                          icon: Icons.people_alt_rounded,
                          color: primaryColor,
                          tint: const Color(0xFFEAF3FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Favorit Berdasarkan Pengguna',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Daftar Favorit dikelompokkan berdasarkan akun masing-masing.',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...data.profiles.map((profile) {
                    final codes = favoritesByUser[profile.id] ?? [];

                    return _buildAdminUserCard(
                      profile: profile,
                      courseCodes: codes,
                      courses: courses,
                    );
                  }),
                  if (data.profiles.isEmpty) _buildEmptyState(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdminSummaryCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  maxLines: 2,
                  style: const TextStyle(
                    color: mutedColor,
                    fontSize: 10,
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

  Widget _buildProfileError() {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Favorit'),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _buildProfileError();
        }

        final profile = snapshot.data!;

        if (profile.isAdmin) {
          final courses = context.watch<CourseProvider>().courses;

          return _buildAdminFavorites(context, courses);
        }

        return _buildPersonalFavorites(context);
      },
    );
  }
}
