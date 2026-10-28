import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/course_state.dart';
import 'providers/course_provider.dart';
import 'services/course_data_source.dart';
import 'services/course_api_service.dart';
import 'repositories/course_repository.dart';
import 'screens/home_page.dart';

const String studentName = 'Kadek Martini Aristianti';
const String studentId = '2415051004';

const String apiBaseUrl = 'https://course-api-pearl.vercel.app';

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CourseState>(
          create: (_) => CourseState(),
        ),
        ChangeNotifierProvider<CourseProvider>(
          create: (_) {
            final CourseDataSource dataSource =
                CourseApiService(apiBaseUrl);

            final CourseRepository repository =
                CourseRepository(dataSource);

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