import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'app_keys.dart';
import 'config/supabase_config.dart';
import 'providers/course_state.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/login_page.dart';
import 'screens/responsive_shell.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  final CourseDataSource dataSource = CourseSupabaseService();
  final CourseRepository repository = CourseRepository(dataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CourseState>(create: (_) => CourseState()),
        ChangeNotifierProvider<CourseProvider>(
          create: (_) {
            final provider = CourseProvider(repository);

            if (AuthService.instance.isLoggedIn) {
              provider.loadCourses();
            }

            return provider;
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
      title: 'Course Data Manager',
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F8FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F8FC),
          foregroundColor: Color(0xFF26364A),
          iconTheme: IconThemeData(color: Color(0xFF26364A)),
          actionsIconTheme: IconThemeData(color: Color(0xFF26364A)),
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: AuthService.instance.isLoggedIn
          ? const ResponsiveShell()
          : const LoginPage(),
    );
  }
}
