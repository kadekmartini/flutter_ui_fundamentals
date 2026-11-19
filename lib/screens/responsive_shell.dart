import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_state.dart';
import '../services/profile_service.dart';
import 'home_page.dart' show HomeTab, ProfileTab;
import 'course_list_page.dart';
import 'favorites_page.dart';
import 'my_courses_page.dart';

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);

  int _selectedIndex = 0;

  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileAndFavorites();
  }

  Future<UserProfile?> _loadProfileAndFavorites() async {
    final profile = await ProfileService().getMyProfile();

    if (profile == null || !mounted) {
      return profile;
    }

    await context.read<CourseState>().loadFavorites(forceRefresh: true);

    return profile;
  }

  List<Widget> _buildPages(String role) {
    return [
      const HomeTab(),
      const CourseListPage(),
      if (role == 'instructor') const MyCoursesPage(),
      const FavoritesPage(),
      const ProfileTab(),
    ];
  }

  List<NavigationDestination> _buildDestinations(String role) {
    return [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Beranda',
      ),
      const NavigationDestination(
        icon: Icon(Icons.school_outlined),
        selectedIcon: Icon(Icons.school_rounded),
        label: 'Kursus',
      ),
      if (role == 'instructor')
        const NavigationDestination(
          icon: Icon(Icons.folder_special_outlined),
          selectedIcon: Icon(Icons.folder_special_rounded),
          label: 'Kursus Saya',
        ),
      const NavigationDestination(
        icon: Icon(Icons.favorite_border_rounded),
        selectedIcon: Icon(Icons.favorite_rounded),
        label: 'Favorit',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profil',
      ),
    ];
  }

  List<NavigationRailDestination> _buildRailDestinations(String role) {
    return [
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: Text('Beranda'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.school_outlined),
        selectedIcon: Icon(Icons.school_rounded),
        label: Text('Kursus'),
      ),
      if (role == 'instructor')
        const NavigationRailDestination(
          icon: Icon(Icons.folder_special_outlined),
          selectedIcon: Icon(Icons.folder_special_rounded),
          label: Text('Kursus Saya'),
        ),
      const NavigationRailDestination(
        icon: Icon(Icons.favorite_border_rounded),
        selectedIcon: Icon(Icons.favorite_rounded),
        label: Text('Favorit'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: Text('Profil'),
      ),
    ];
  }

  Widget _buildMobileNavigation(
    List<Widget> pages,
    List<NavigationDestination> destinations,
    int selectedIndex,
  ) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFEAF3FF),
        elevation: 8,
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }

  Widget _buildDesktopNavigation(
    List<Widget> pages,
    List<NavigationRailDestination> destinations,
    int selectedIndex,
  ) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          Container(
            width: 90,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 25),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: NavigationRail(
                    backgroundColor: Colors.white,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    labelType: NavigationRailLabelType.all,
                    indicatorColor: const Color(0xFFEAF3FF),
                    selectedIconTheme: const IconThemeData(color: primaryColor),
                    unselectedIconTheme: const IconThemeData(
                      color: Color(0xFF8190A2),
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: Color(0xFF8190A2),
                      fontSize: 11,
                    ),
                    destinations: destinations,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFFE8EEF5),
          ),
          Expanded(
            child: IndexedStack(index: selectedIndex, children: pages),
          ),
        ],
      ),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: Colors.redAccent,
                size: 42,
              ),
              const SizedBox(height: 13),
              const Text(
                'Gagal Memuat Profil Pengguna',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF26364A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Profil diperlukan untuk menampilkan menu sesuai role.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF718096), fontSize: 12),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _profileFuture = _loadProfileAndFavorites();
                  });
                },
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
          return _buildProfileLoading();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _buildProfileError();
        }

        final role = snapshot.data!.role;

        final pages = _buildPages(role);
        final destinations = _buildDestinations(role);
        final railDestinations = _buildRailDestinations(role);

        final selectedIndex = _selectedIndex < pages.length
            ? _selectedIndex
            : 0;

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 840) {
              return _buildMobileNavigation(pages, destinations, selectedIndex);
            }

            return _buildDesktopNavigation(
              pages,
              railDestinations,
              selectedIndex,
            );
          },
        );
      },
    );
  }
}
