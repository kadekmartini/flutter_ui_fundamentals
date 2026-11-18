
import 'package:flutter/material.dart';

import 'home_page.dart' show HomeTab, ProfileTab;
import 'course_list_page.dart';
import 'favorites_page.dart';

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);

  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    CourseListPage(),
    FavoritesPage(),
    ProfileTab(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Beranda',
    ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school_rounded),
      label: 'Kursus',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_border_rounded),
      selectedIcon: Icon(Icons.favorite_rounded),
      label: 'Favorit',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profil',
    ),
  ];

  final List<NavigationRailDestination> _railDestinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: Text('Beranda'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school_rounded),
      label: Text('Kursus'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.favorite_border_rounded),
      selectedIcon: Icon(Icons.favorite_rounded),
      label: Text('Favorit'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: Text('Profil'),
    ),
  ];

  Widget _buildMobileNavigation() {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFEAF3FF),
        elevation: 8,
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }

  Widget _buildDesktopNavigation() {
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
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    labelType: NavigationRailLabelType.all,
                    indicatorColor: const Color(0xFFEAF3FF),
                    selectedIconTheme: const IconThemeData(
                      color: primaryColor,
                    ),
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
                    destinations: _railDestinations,
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
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return _buildMobileNavigation();
        }

        return _buildDesktopNavigation();
      },
    );
  }
}
