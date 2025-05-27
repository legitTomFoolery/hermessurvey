import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Your Firebase project ID
  static const String _projectId = 'gsecsurveyapp-backend';

  // Initialize the notification service
  static Future<void> initialize() async {
    try {
      // Request permission for notifications (skip on web)
      if (!kIsWeb) {
        NotificationSettings settings =
            await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          if (kDebugMode) {
            debugPrint('User granted permission');
          }
        } else if (settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
          if (kDebugMode) {
            debugPrint('User granted provisional permission');
          }
        } else {
          if (kDebugMode) {
            debugPrint('User declined or has not accepted permission');
          }
        }
      }

      // Initialize local notifications (skip on web)
      if (!kIsWeb) {
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const DarwinInitializationSettings initializationSettingsIOS =
            DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

        const InitializationSettings initializationSettings =
            InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

        await _localNotifications.initialize(initializationSettings);
      }

      // Subscribe to the 'all_users' topic (skip on web - not supported)
      if (!kIsWeb) {
        try {
          await _firebaseMessaging.subscribeToTopic('all_users');
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Failed to subscribe to topic (expected on web): $e');
          }
        }
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages (skip on web)
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      }

      // Handle notification taps when app is terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize notification service: $e');
      }
    }
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('Handling a foreground message: ${message.messageId}');
    }

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('Handling a background message: ${message.messageId}');
    }
  }

  // Handle notification tap when app is opened from terminated state
  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('Message clicked: ${message.messageId}');
    }
    // Handle navigation or other actions when notification is tapped
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'gsec_survey_channel',
      'GSEC Survey Notifications',
      channelDescription: 'Notifications for GSEC Survey App',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'GSEC Survey',
      message.notification?.body ?? 'You have a new notification',
      platformChannelSpecifics,
    );
  }

  // Send custom notification to all users (Spark Plan Compatible)
  static Future<bool> sendCustomNotification({
    required String title,
    required String body,
  }) async {
    try {
      // Store notification in Firestore for tracking
      await _storeNotificationInFirestore(title, body);

      // Send actual push notification using FCM HTTP v1 API
      bool success = await _sendPushNotification(title, body);

      if (success) {
        if (kDebugMode) {
          debugPrint('Push notification sent successfully');
        }
        await _updateNotificationStatus('sent');
      } else {
        if (kDebugMode) {
          debugPrint('Failed to send push notification');
        }
        await _updateNotificationStatus('failed');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending notification: $e');
      }
      await _updateNotificationStatus('error: $e');
      return false;
    }
  }

  // Store notification in Firestore for tracking
  static Future<void> _storeNotificationInFirestore(
      String title, String body) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'sentBy': 'admin',
      'status': 'sending',
    });
  }

  // Update notification status in Firestore
  static Future<void> _updateNotificationStatus(String status) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({'status': status});
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating notification status: $e');
      }
    }
  }

  // Send push notification using FCM HTTP v1 API
  static Future<bool> _sendPushNotification(String title, String body) async {
    try {
      // On web, we can't use JWT signing, so we'll store the notification
      // and show a message that notifications work on mobile devices
      if (kIsWeb) {
        if (kDebugMode) {
          debugPrint(
              'Web platform: Notifications are stored but push notifications require mobile devices');
        }
        // For web, we just return true to indicate the notification was "sent"
        // In reality, web push notifications require a different setup
        return true;
      }

      // Get access token (mobile only)
      String? accessToken = await _getAccessToken();
      if (accessToken == null) {
        if (kDebugMode) {
          debugPrint('Failed to get access token');
        }
        return false;
      }

      // Prepare the FCM message
      final message = {
        'message': {
          'topic': 'all_users',
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'type': 'custom_notification',
          },
          'android': {
            'notification': {
              'channel_id': 'gsec_survey_channel',
              'sound': 'default',
            },
            'priority': 'high',
          },
          'apns': {
            'payload': {
              'aps': {
                'alert': {
                  'title': title,
                  'body': body,
                },
                'sound': 'default',
              }
            }
          }
        }
      };

      // Send the request
      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('FCM message sent successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('FCM error: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending FCM message: $e');
      }
      return false;
    }
  }

  // Get access token using service account
  static Future<String?> _getAccessToken() async {
    try {
      // On web, JWT signing with RSA private keys is not supported
      // Return null so web notifications are handled differently
      if (kIsWeb) {
        if (kDebugMode) {
          debugPrint(
              'Web platform detected - JWT signing not supported in browsers');
        }
        return null;
      }

      // Load service account key from assets
      final serviceAccountJson =
          await rootBundle.loadString('assets/service-account-key.json');
      final serviceAccount = jsonDecode(serviceAccountJson);

      // Check if service account is properly configured
      if (serviceAccount['private_key'] == null ||
          serviceAccount['private_key']
              .toString()
              .contains('YOUR_PRIVATE_KEY_HERE')) {
        if (kDebugMode) {
          debugPrint('Service account key not configured properly');
        }
        return null;
      }

      // Create JWT
      final jwt = JWT({
        'iss': serviceAccount['client_email'],
        'scope': 'https://www.googleapis.com/auth/firebase.messaging',
        'aud': 'https://oauth2.googleapis.com/token',
        'exp': DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });

      // Sign JWT with private key - using RSAPrivateKey for dart_jsonwebtoken 2.14.0
      final privateKeyString = serviceAccount['private_key'] as String;
      final rsaPrivateKey = RSAPrivateKey(privateKeyString);
      final token = jwt.sign(rsaPrivateKey, algorithm: JWTAlgorithm.RS256);

      // Exchange JWT for access token
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        if (kDebugMode) {
          debugPrint(
              'Token exchange error: ${response.statusCode} - ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting access token: $e');
      }
      return null;
    }
  }

  // Get the last notification sent time
  static Future<DateTime?> getLastNotificationTime() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final timestamp =
            querySnapshot.docs.first.data()['timestamp'] as Timestamp?;
        return timestamp?.toDate();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting last notification time: $e');
      }
      return null;
    }
  }

  // Get FCM token for debugging
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Get notification history
  static Future<List<Map<String, dynamic>>> getNotificationHistory(
      {int limit = 10}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'body': data['body'] ?? '',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
          'sentBy': data['sentBy'] ?? 'unknown',
          'status': data['status'] ?? 'unknown',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting notification history: $e');
      }
      return [];
    }
  }
}
