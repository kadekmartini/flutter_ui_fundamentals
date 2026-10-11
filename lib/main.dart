// TAHAP 12: Refactor Struktur Folder
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Mengimpor dari struktur folder yang sudah dirapikan
import 'providers/course_state.dart';
import 'providers/course_provider.dart';
import 'services/course_service.dart';
import 'repositories/course_repository.dart';
import 'screens/home_page.dart'; // File baru yang membungkus semua screen

const String studentName = 'Kadek Martini Aristianti';
const String studentId = '2415051004';

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