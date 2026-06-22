import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(requestAlertPermission: true);

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showGameSavedNotification({
    required int gameId,
    required String gameTitle,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'saved_games',
      'Saved Games',
      channelDescription: 'Notifications when a game is saved.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: gameId,
      title: 'Game saved',
      body: '$gameTitle was added to your saved games.',
      notificationDetails: details,
    );
  }

  Future<void> showRecommendationReminder() async {
    // Placeholder for future reminder notifications.
  }
}
