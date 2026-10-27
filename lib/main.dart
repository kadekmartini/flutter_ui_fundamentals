import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Tahap 2: Untuk membaca JSON
import 'package:http/http.dart' as http; // Tahap 2: Package HTTP

import 'models/course.dart'; // Tahap 3: Model Course
import 'providers/course_state.dart';
import 'providers/course_provider.dart';
import 'services/course_service.dart';
import 'repositories/course_repository.dart';
import 'screens/home_page.dart'; 

const String studentName = 'Kadek Martini Aristianti';
const String studentId = '2415051004';

// ==========================================
// KODE TAHAP 2 + TAHAP 3
// ==========================================
const String apiUrl = 'https://course-api-pearl.vercel.app/courses';

// TAHAP 3: mengembalikan List<Course> (sebelumnya List<dynamic> pada Tahap 2)
Future<List<Course>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  throw Exception('HTTP ${response.statusCode}');
}
// ==========================================

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

  // ==========================================
  // TES TAHAP 3 (Mencetak hasil konversi JSON -> List<Course> di Debug Console)
  // ==========================================
  fetchCourses().then((courses) {
    debugPrint('BERHASIL TAHAP 3! Jumlah course: ${courses.length}');
    for (final c in courses.take(3)) {
      debugPrint('code=${c.code} | title=${c.title} | status=${c.status}');
    }
  }).catchError((e) {
    debugPrint('ERROR TAHAP 3: $e');
  });
  // ==========================================

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CourseState()),
        ChangeNotifierProvider(
          create: (context) {
            final service = CourseService();
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