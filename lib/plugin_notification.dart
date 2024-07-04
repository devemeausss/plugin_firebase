import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:plugin_firebase/plugin_firebase.dart';

class MyPluginNotification {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static StreamSubscription? _fcmListener;

  static Future<void> _showNotification({
    required String title,
    required String body,
    required Color color,
    String? payload,
    required int hashCode,
    chanelId,
    chanelName,
    channelDescription,
    String? icon,
  }) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      chanelId,
      chanelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      showProgress: true,
      priority: Priority.high,
      color: color,
      icon: icon,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: payload ?? '',
    );
  }

  static Future<void> settingNotification(
      {String? currentFCMToken,
      String? currentIMEI,
      required Color colorNotification,
      required bool Function(RemoteMessage message) onShowLocalNotification,
      bool isShowLocalNotificationFromFirebase = true,
      required Function(RemoteMessage message) onMessage,
      required Function(String payload) onOpenLocalMessage,
      required Function(RemoteMessage message) onOpenFCMMessage,
      required Function(Map<String, dynamic> token) onRegisterFCM,
      String? iconNotification,
      required String chanelId,
      required String chanelName,
      required String channelDescription}) async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // var initializationSettingsAndroid =
      //     AndroidInitializationSettings(iconNotification);
      // var initializationSettingsIOS = const DarwinInitializationSettings();
      // var initializationSettings = InitializationSettings(
      //     android: initializationSettingsAndroid,
      //     iOS: initializationSettingsIOS);

      var channel = AndroidNotificationChannel(
        chanelId, // id
        chanelName, // title
        description: channelDescription, // description
        importance: Importance.high,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      Map<String, dynamic> body = await getInfoToRequest(
          currentFCMToken: currentFCMToken, currentIMEI: currentIMEI);
      onRegisterFCM(body);
      _fcmListener =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('Got a message whilst in the foreground!');
        onMessage(message);
        if (message.notification != null) {
          if (onShowLocalNotification(message) && Platform.isAndroid) {
            await _showNotification(
              hashCode: message.notification!.hashCode,
              title: message.notification!.title!,
              body: message.notification!.body!,
              color: colorNotification,
              // payload: jsonEncode(message.data),
              chanelId: chanelId,
              chanelName: chanelName,
              channelDescription: channelDescription,
              icon: iconNotification,
            );
          }
        }
      });
      _setupInteractedMessage(onHandleFCMMessage: onOpenFCMMessage);
    }
  }

  static Future<void> _setupInteractedMessage(
      {required Function onHandleFCMMessage}) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      onHandleFCMMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => onHandleFCMMessage(message));
  }

  static void setupCrashlytics({required VoidCallback main}) {
    runZonedGuarded<Future<void>>(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      main();
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      }
    },
        (error, stack) =>
            FirebaseCrashlytics.instance.recordError(error, stack));
  }

  static Future<Map<String, dynamic>> getInfoToRequest(
      {String? currentFCMToken, String? currentIMEI}) async {
    String? token = currentFCMToken;
    token ??= await _messaging.getToken();

    String meId = await MyPluginFirebase.getMeIdDevice(currentIMEI);
    Map<String, dynamic> body = {
      "type": "M", // M: Mobile, P: Portal
      "device": Platform.isAndroid ? "A" : "I", // A: Android, I: iOS
      "meid": meId,
      "token": token,
    };
    return body;
  }

  static dispose() {
    _fcmListener?.cancel();
  }
}
