import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // App may already be initialized or config may be missing in dev.
  }
  log('Background message received: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final token = await messaging.getToken();
      log('FCM token: $token');

      await messaging.subscribeToTopic('fitquest_all');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? 'FitQuest Notification';
        final body = message.notification?.body ?? 'You received a new update.';
        _showInAppMessage('$title\n$body');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _showInAppMessage(
          'Opened notification: ${message.notification?.title ?? 'FitQuest'}',
        );
      });

      _initialized = true;
      log('Notification service initialized');
    } catch (error) {
      log('Notification initialization skipped: $error');
    }
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final messaging = FirebaseMessaging.instance;
      if (enabled) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        await messaging.subscribeToTopic('fitquest_all');
      } else {
        await messaging.unsubscribeFromTopic('fitquest_all');
      }
    } catch (error) {
      log('Failed to update notification preference: $error');
    }
  }

  static Future<String?> getDeviceToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (error) {
      log('Failed to read FCM token: $error');
      return null;
    }
  }

  static void _showInAppMessage(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }
}
