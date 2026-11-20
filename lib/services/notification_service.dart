import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_keys.dart';
import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('[BACKGROUND] ${message.notification?.title}');
  debugPrint('[BACKGROUND] ${message.notification?.body}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _webVapidKey =
      'BGDcN8NZuaDVBhMo8haPiC_3wfD-SYBKfrqB2kDkRm8pFzbw1YsKL8L-pzvQRW04oP0xfmPGiH87BjB_64v1y2Q';

  bool _initialized = false;

  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus.name}');

    return settings.authorizationStatus;
  }

  Future<String?> getToken() async {
    try {
      // ignore: deprecated_member_use
      final token = await _messaging.getToken(
        vapidKey: kIsWeb ? _webVapidKey : null,
      );

      debugPrint('FCM Token: $token');

      return token;
    } catch (error) {
      debugPrint('Gagal mendapatkan FCM Token: $error');
      return null;
    }
  }

  void listenTokenRefresh(void Function(String token) onRefresh) {
    // ignore: deprecated_member_use
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token diperbarui');
      onRefresh(newToken);
    });
  }

  Future<void> init() async {
    if (_initialized) return;

    _initialized = true;

    final status = await requestPermission();

    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      await getToken();
    }

    listenTokenRefresh((token) {
      debugPrint('FCM Token baru diterima');
    });

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FOREGROUND] Notification received');
      debugPrint('title: ${message.notification?.title}');
      debugPrint('body : ${message.notification?.body}');
      debugPrint('data : ${message.data}');

      final title = message.notification?.title ?? 'Notifikasi';
      final body = message.notification?.body ?? '';

      messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('$title\n$body')),
      );
    });
  }
}
