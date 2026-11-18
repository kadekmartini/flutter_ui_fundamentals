
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';
import 'course_detail_page.dart';
import 'home_page.dart' show StudentIdentityBanner;

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF26364A);
  static const Color mutedColor = Color(0xFF718096);

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

  Widget _buildHeader(int totalFavorites) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
                Text(
                  'Kumpulan kursus pilihan yang kamu simpan.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EEF5),
        ),
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
              color: Color(0xFFE34D68),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              totalFavorites.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFFE34D68),
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
                color: Color(0xFFE34D68),
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
              'Simpan kursus yang kamu sukai dengan menekan menu favorit pada kartu kursus.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedColor,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CourseProvider provider,
    CourseState favoriteState,
    List<Course> favoriteCourses,
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

    if (favoriteCourses.isEmpty) {
      return _buildEmptyState();
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
                top: 3,
                bottom: 25,
              ),
              itemCount: favoriteCourses.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = favoriteCourses[index];

                return InteractiveCourseCard(
                  course: course,
                  onTap: () => _openDetail(context, course),
                  showFavoriteButton: true,
                  isFavorite: true,
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final favoriteState = context.watch<CourseState>();

    final favoriteCourses = provider.courses
        .where(
          (course) => favoriteState.isFavorite(course.code),
        )
        .toList();

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
            tooltip: 'Muat Ulang Favorit',
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
                constraints: const BoxConstraints(
                  maxWidth: 1050,
                ),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: _buildContent(
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
}
