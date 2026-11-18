
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../providers/course_state.dart';
import '../widgets/course_card.dart';

const String studentName = 'Kadek Martini Aristianti';
const String studentId = '2415051004';

class StudentIdentityBanner extends StatelessWidget {
  const StudentIdentityBanner({
    super.key,
    this.name = studentName,
    this.nim = studentId,
  });

  final String name;
  final String nim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0EAF5),
        ),
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
              Icons.person_rounded,
              color: Color(0xFF1976D2),
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'IDENTITAS MAHASISWA',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF26364A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'NIM: $nim',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF26364A);
  static const Color mutedColor = Color(0xFF718096);

  Widget _buildWelcomeBanner() {
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
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -18,
            child: Icon(
              Icons.school_rounded,
              size: 115,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Column(
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
                  'APLIKASI MANAJEMEN KURSUS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kelola dan pantau aktivitas pembelajaranmu dalam satu tempat.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE8EEF5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor,
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

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: mutedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8EEF5),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 46,
            color: Color(0xFF1976D2),
          ),
          SizedBox(height: 14),
          Text(
            'Belum Ada Kursus',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Data kursus yang tersedia akan ditampilkan di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mutedColor,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String message,
    VoidCallback onRetry,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFDADA),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: Colors.red.shade400,
            size: 38,
          ),
          const SizedBox(height: 12),
          const Text(
            'Gagal Memuat Data',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final courseState = context.watch<CourseState>();

    final courses = courseProvider.courses;
    final favoritesCount = courseState.favorites.length;

    final activeCount =
        courses.where((course) => course.status == 'active').length;

    final completedCount =
        courses.where((course) => course.status == 'done').length;

    final latestCourses = courses.reversed.take(5).toList();

    final stats = [
      {
        'title': 'Total Kursus',
        'value': courses.length,
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF1976D2),
        'background': const Color(0xFFEAF3FF),
      },
      {
        'title': 'Favorit',
        'value': favoritesCount,
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFE34D68),
        'background': const Color(0xFFFFF0F2),
      },
      {
        'title': 'Sedang Berjalan',
        'value': activeCount,
        'icon': Icons.schedule_rounded,
        'color': const Color(0xFFD78A24),
        'background': const Color(0xFFFFF5E8),
      },
      {
        'title': 'Selesai',
        'value': completedCount,
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF199B60),
        'background': const Color(0xFFE9F8EF),
      },
    ];

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
              size: 27,
            ),
            SizedBox(width: 10),
            Text(
              'Manajemen Kursus',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat Ulang Data',
            onPressed: courseProvider.isLoading
                ? null
                : () => courseProvider.loadCourses(),
            icon: const Icon(
              Icons.refresh_rounded,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: courseProvider.loadCourses,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeBanner(),
                  const SizedBox(height: 15),
                  const StudentIdentityBanner(),
                  const SizedBox(height: 27),
                  _buildSectionHeader(
                    title: 'Ringkasan Aktivitas',
                    subtitle: 'Informasi kursus dan pembelajaranmu.',
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          constraints.maxWidth >= 760 ? 4 : 2;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stats.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 11,
                          mainAxisSpacing: 11,
                          childAspectRatio:
                              columns == 2 ? 1.55 : 2.15,
                        ),
                        itemBuilder: (context, index) {
                          final stat = stats[index];

                          return _buildStatCard(
                            title: stat['title'] as String,
                            value: stat['value'] as int,
                            icon: stat['icon'] as IconData,
                            color: stat['color'] as Color,
                            background:
                                stat['background'] as Color,
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  _buildSectionHeader(
                    title: 'Kursus Terbaru',
                    subtitle: 'Lima kursus terbaru dari daftar pembelajaran.',
                  ),
                  const SizedBox(height: 14),
                  if (courseProvider.isLoading && courses.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(35),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (courseProvider.error != null &&
                      courses.isEmpty)
                    _buildErrorState(
                      courseProvider.error!,
                      () => courseProvider.loadCourses(),
                    )
                  else if (courses.isEmpty)
                    _buildEmptyState()
                  else
                    Column(
                      children: [
                        ...latestCourses.map((course) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InteractiveCourseCard(
                              course: course,
                              showFavoriteButton: true,
                              isFavorite:
                                  courseState.isFavorite(course.code),
                              onToggleFavorite: () {
                                courseState.toggleFavorite(course.code);
                              },
                            ),
                          );
                        }),
                        if (courses.length > 5)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Lihat seluruh kursus melalui menu Kursus.',
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (courseProvider.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _nimController;

  final TextEditingController _commentController =
      TextEditingController();

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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Konfirmasi Pengiriman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Kirim masukan atau feedback ini sekarang?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Feedback berhasil diproses.'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
      ),
    );

    _commentController.clear();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF4F8FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE8EEF5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFF1976D2),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeTab.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: HomeTab.textColor,
          ),
        ),
        backgroundColor: HomeTab.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE8EEF5),
                      ),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 48,
                          backgroundColor: Color(0xFFEAF3FF),
                          backgroundImage: AssetImage(
                            'assets/images/profile.jpeg',
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          studentName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: HomeTab.textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'NIM: $studentId',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: HomeTab.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 13),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Mahasiswa Pendidikan Teknik Informatika',
                            style: TextStyle(
                              fontSize: 11,
                              color: HomeTab.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Informasi Akademik',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: HomeTab.textColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE8EEF5),
                      ),
                    ),
                    child: const Column(
                      children: [
                        _ProfileInfoTile(
                          icon: Icons.school_outlined,
                          title: 'Program Studi',
                          subtitle: 'Pendidikan Teknik Informatika',
                        ),
                        Divider(height: 25),
                        _ProfileInfoTile(
                          icon: Icons.account_balance_outlined,
                          title: 'Universitas',
                          subtitle: 'Universitas Pendidikan Ganesha',
                        ),
                        Divider(height: 25),
                        _ProfileInfoTile(
                          icon: Icons.badge_outlined,
                          title: 'Nomor Induk Mahasiswa',
                          subtitle: studentId,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Fokus Pembelajaran',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: HomeTab.textColor,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      'Flutter',
                      'Dart',
                      'Laravel',
                      'Git & GitHub',
                      'Networking',
                      'UI/UX Design',
                    ].map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE8EEF5),
                          ),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: HomeTab.textColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Feedback dan Masukan',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: HomeTab.textColor,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE8EEF5),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              'Nama Lengkap',
                              Icons.person_outline,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Nama wajib diisi'
                                    : null,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _nimController,
                            decoration: _inputDecoration(
                              'NIM',
                              Icons.badge_outlined,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'NIM wajib diisi'
                                    : null,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _commentController,
                            maxLines: 4,
                            decoration: _inputDecoration(
                              'Komentar atau Pesan',
                              Icons.chat_bubble_outline,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Komentar wajib diisi'
                                    : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            child: FilledButton.icon(
                              onPressed:
                                  _isLoading ? null : _submitForm,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: Text(
                                _isLoading
                                    ? 'Memproses...'
                                    : 'Kirim Feedback',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: HomeTab.primaryColor,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: HomeTab.mutedColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: HomeTab.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
