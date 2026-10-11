import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_state.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../main.dart'; // Untuk mengakses konstanta nama dan fungsi helper
// TAHAP 13: Import halaman favorites
import 'favorites_page.dart';

// ==========================================
// MainScreen Adaptive Navigation
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; 
  final List<Widget> _pages = const [
    HomeTab(),
    CoursesTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Scaffold(
            body: _pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Colors.blue), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school, color: Colors.blue), label: 'Courses'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Colors.blue), label: 'Profile'),
              ],
            ),
          );
        }
        
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                backgroundColor: Colors.white,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Colors.blue), label: Text('Home')),
                  NavigationRailDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school, color: Colors.blue), label: Text('Courses')),
                  NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Colors.blue), label: Text('Profile')),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1, color: Colors.black12),
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// TAB 1: HomeTab
// ==========================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nimController;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: studentName);
    _nimController = TextEditingController(text: studentId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Konfirmasi', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Kirim masukan atau feedback ini sekarang?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true), 
              child: const Text('Kirim'),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 12), Text('Feedback berhasil dikirim!')]),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 24),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Utama', style: TextStyle(fontWeight: FontWeight.w700))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) return const CompactLayout();
                  if (constraints.maxWidth < 840) return const MediumLayout();
                  return const ExpandedLayout();
                },
              ),
              _buildSectionTitle('Informasi Pengguna'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Icon(Icons.person_pin, size: 18, color: Colors.blue.shade600), const SizedBox(width: 6), Text('Profil Singkat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13))]),
                          const SizedBox(height: 12),
                          const Text(studentName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text('NIM: $studentId', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400]), borderRadius: BorderRadius.circular(16)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Semester', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70, fontSize: 12)),
                          SizedBox(height: 4),
                          Text('5', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              _buildSectionTitle('Fokus Pembelajaran'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <String>[
                  'Flutter', 'Dart', 'Laravel', 'Git & GitHub', 'Networking', 'UI/UX Design'
                ].map<Widget>((String skill) => Chip(
                  label: Text(skill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                )).toList(),
              ),
              
              _buildSectionTitle('Kirim Feedback & Masukan'),
              Card(
                color: Colors.white,
                elevation: 1.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nimController,
                          decoration: InputDecoration(
                            labelText: 'NIM',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'NIM wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Komentar atau Pesan',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Komentar wajib diisi' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submitForm,
                            icon: _isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send_rounded),
                            label: Text(_isLoading ? 'Memproses...' : 'Kirim Sekarang', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 2: CoursesTab
// ==========================================
class CoursesTab extends StatefulWidget {
  const CoursesTab({super.key});

  @override
  State<CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<CoursesTab> {

  int columnsFor(double width) {
    if (width < 600) return 1;
    if (width < 840) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final int favoriteCount = context.watch<CourseState>().favorites.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Materi', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          // TAHAP 13: Tambahkan tombol ini untuk membuka halaman FavoritesPage
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            tooltip: 'Lihat Favorit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          if (courseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (courseProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Gagal memuat data: ${courseProvider.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => courseProvider.loadCourses(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          final List<Course> courses = courseProvider.courses;
          if (courses.isEmpty) {
             return const Center(child: Text('Tidak ada materi yang tersedia.'));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('Daftar Modul:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade200)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: Colors.red.shade500, size: 16),
                        const SizedBox(width: 6),
                        Text('Total Materi Favorit: $favoriteCount', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnsFor(constraints.maxWidth),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: constraints.maxWidth < 600 ? 2.8 : 2.2, 
                        ),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          return InteractiveCourseCard(course: courses[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// TAB 3: ProfileTab
// ==========================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.w700))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade100, width: 4),
              ),
              child: const CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xFFE3F2FD),
                backgroundImage: AssetImage('assets/images/profile.jpeg'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              studentName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'NIM: $studentId',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
              ),
            ),
            const SizedBox(height: 40),
            
            Card(
              color: Colors.white,
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.school, color: Colors.blue.shade700, size: 22),
                      ),
                      title: const Text('Program Studi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: const Text('Pendidikan Teknik Informatika', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                    const Divider(height: 1, indent: 70, endIndent: 20, color: Colors.black12),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.account_balance, color: Colors.green.shade700, size: 22),
                      ),
                      title: const Text('Universitas', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: const Text('Universitas Pendidikan Ganesha', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET LAYOUT BREAKPOINT
// ==========================================
class CompactLayout extends StatelessWidget {
  const CompactLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade100)),
      child: Row(
        children: [
          Icon(Icons.phone_android, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 12),
          Text('Tampilan Layar HP (Compact)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13)),
        ],
      ),
    );
  }
}
class MediumLayout extends StatelessWidget {
  const MediumLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.purple.shade100)),
      child: Row(
        children: [
          Icon(Icons.tablet_mac, color: Colors.purple.shade600, size: 20),
          const SizedBox(width: 12),
          Text('Tampilan Layar Tablet (Medium)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade700, fontSize: 13)),
        ],
      ),
    );
  }
}
class ExpandedLayout extends StatelessWidget {
  const ExpandedLayout({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.shade100)),
      child: Row(
        children: [
          Icon(Icons.desktop_windows, color: Colors.teal.shade600, size: 20),
          const SizedBox(width: 12),
          Text('Tampilan Desktop / Web (Expanded)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700, fontSize: 13)),
        ],
      ),
    );
  }
}