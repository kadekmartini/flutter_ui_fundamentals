import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// [TAHAP 4 - DIHAPUS] import 'dart:convert' dan 'package:http/http.dart'
// tidak lagi dipakai di sini, karena request HTTP dipindah ke CourseApiService.
// [TAHAP 4 - DIHAPUS] import 'models/course.dart' ikut dihapus karena
// fungsi fetchCourses() yang memakainya sudah dipindah ke service.
import 'providers/course_state.dart';
import 'providers/course_provider.dart';
import 'services/course_api_service.dart'; // [TAHAP 4 - BARU] menggantikan course_service.dart
import 'repositories/course_repository.dart';
import 'screens/home_page.dart';

const String studentName = 'Kadek Martini Aristianti';
const String studentId = '2415051004';

// ==========================================
// [TAHAP 4 - DIUBAH]
// Sebelumnya (Tahap 2): apiUrl = '.../courses'
// Sekarang: base URL saja TANPA '/courses', karena path '/courses'
// ditambahkan di dalam CourseApiService.getCourses().
// ==========================================
const String apiBaseUrl = 'https://course-api-pearl.vercel.app';

// [TAHAP 4 - DIHAPUS] Fungsi fetchCourses() (kode GET sementara Tahap 2-3)
// sudah dipindahkan ke lib/services/course_api_service.dart.

String getStatusText(String status) {
  if (status == 'done') return 'Selesai';
  if (status == 'active') return 'Berjalan';
  return 'Terencana';
}

Color getStatusColor(String status) {
  if (status == 'done') return Colors.green.shade600;
  if (status == 'active') return Colors.orange.shade700;
  return Colors.grey.shade600;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // [TAHAP 4 - DIHAPUS] Blok tes fetchCourses() di sini dihapus.
  // Pemanggilan data sekarang berjalan lewat:
  // CourseProvider -> CourseRepository -> CourseApiService.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CourseState()),
        ChangeNotifierProvider(
          create: (context) {
            // [TAHAP 4 - DIUBAH] sebelumnya: final service = CourseService();
            final service = CourseApiService(apiBaseUrl);
            final repository = CourseRepository(service);
            return CourseProvider(repository)..loadCourses();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          shadowColor: Colors.black12,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const MainScreen(),
    );
  }
}