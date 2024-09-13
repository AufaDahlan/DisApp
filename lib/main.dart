import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realtime/firebase_options.dart';
import 'package:realtime/pages/chat.dart';
import 'package:realtime/pages/fillprofil.dart';
import 'package:realtime/pages/home.dart';
import 'package:realtime/pages/login.dart';
import 'package:realtime/pages/splash.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Notification clicked with data: ${message.data}");
  if (message.data.isNotEmpty) {
    final title = message.data['title'] ?? 'No Title';
    final messageType = message.data['messageType'] ?? 'text';
    final body = messageType == "text"
        ? message.data['body'] ?? 'No Message'
        : messageType == "file"
            ? " ${message.data['body']}"
            : "🖼️ Image";
    final data = message.data;
    final roomId = data['roomId'] ?? '';
    final nama = data['nama'] ?? '';
    final profilePicture = data['profilePicture'] ?? '';
    final targetUserID = data['targetUserID'] ?? '';
    final email = data['email'] ?? '';
    final telepon = data['telepon'] ?? '';

    MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          roomId: roomId,
          nama: nama,
          profilePicture: profilePicture,
          targetUserID: targetUserID,
          email: email,
          telepon: telepon,
        ),
      ),
    );
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _requestPermissions();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  UserDataCheckResult result = await _checkUserData();
  MyApp.userDataCheckResult = result; // Simpan hasil pengecekan user data

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/icon');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data.isNotEmpty) {
      // Tangkap data dari payload
      final title = message.data['title'] ?? 'No Title';
      final messageType = message.data['messageType'] ?? 'text';
      final body = messageType == "text"
          ? message.data['body'] ?? 'No Message'
          : messageType == "file"
              ? " ${message.data['body']}"
              : "🖼️ Image";
      final data = message.data;
      final roomId = data['roomId'] ?? '';
      final nama = data['nama'] ?? '';
      final profilePicture = data['profilePicture'] ?? '';
      final targetUserID = data['targetUserID'] ?? '';
      final email = data['email'] ?? '';
      final telepon = data['telepon'] ?? '';

      flutterLocalNotificationsPlugin.show(
        0,
        title ?? '',
        body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode({
          'roomId': roomId,
          'nama': nama,
          'profilePicture': profilePicture,
          'targetUserID': targetUserID,
          'email': email,
          'telepon': telepon,
        }),
      );
    }
  });

// Listener untuk saat notifikasi dibuka dari tray (foreground & background)
  flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/icon'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        final roomId = data['roomId'];
        final nama = data['nama'];
        final profilePicture = data['profilePicture'];
        final targetUserID = data['targetUserID'];
        final email = data['email'];
        final telepon = data['telepon'];

        MyApp.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              roomId: roomId,
              nama: nama,
              profilePicture: profilePicture,
              targetUserID: targetUserID,
              email: email,
              telepon: telepon,
            ),
          ),
        );
      }
    },
  );

// Listener untuk ketika aplikasi dibuka dari background atau terminated
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data.isNotEmpty) {
      final title = message.data['title'] ?? 'No Title';
      final messageType = message.data['messageType'] ?? 'text';
      final body = messageType == "text"
          ? message.data['body'] ?? 'No Message'
          : messageType == "file"
              ? " ${message.data['body']}"
              : "🖼️ Image";
      final data = message.data;
      final roomId = data['roomId'] ?? '';
      final nama = data['nama'] ?? '';
      final profilePicture = data['profilePicture'] ?? '';
      final targetUserID = data['targetUserID'] ?? '';
      final email = data['email'] ?? '';
      final telepon = data['telepon'] ?? '';

      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            roomId: roomId,
            nama: nama,
            profilePicture: profilePicture,
            targetUserID: targetUserID,
            email: email,
            telepon: telepon,
          ),
        ),
      );
    }
  });

  runApp(MyApp());
}

Future<void> _requestPermissions() async {
  // Meminta izin notifikasi
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Meminta izin storage
  if (await Permission.storage.isDenied) {
    await Permission.storage.request();
  }
}

Future<UserDataCheckResult> _checkUserData() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.json');

    if (await file.exists()) {
      String fileContent = await file.readAsString();
      Map<String, dynamic> userData = json.decode(fileContent);

      if (_isUserDataComplete(userData)) {
        return UserDataCheckResult(userDataComplete: true, hasUserData: true);
      } else {
        return UserDataCheckResult(userDataComplete: false, hasUserData: true);
      }
    }
    return UserDataCheckResult(userDataComplete: false, hasUserData: false);
  } catch (e) {
    print('Error checking userdata file: $e');
    return UserDataCheckResult(userDataComplete: false, hasUserData: false);
  }
}

bool _isUserDataComplete(Map<String, dynamic> userData) {
  if (userData['nama'] == '' ||
      userData['email'] == '' ||
      userData['telepon'] == '' ||
      userData['uid'] == '') {
    return false;
  }
  return true;
}

class UserDataCheckResult {
  final bool userDataComplete;
  final bool hasUserData;

  UserDataCheckResult(
      {required this.userDataComplete, required this.hasUserData});
}

class MyApp extends StatelessWidget {
  static late UserDataCheckResult userDataCheckResult;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'DisApp',
      home: SplashScreenPage(),
      routes: {
        '/chat': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return ChatScreen(
            roomId: args?['roomId'] ?? '',
            nama: args?['nama'] ?? '',
            profilePicture: args?['profilePicture'] ?? '',
            targetUserID: args?['targetUserID'] ?? '',
            email: args?['email'] ?? '',
            telepon: args?['telepon'] ?? '',
          );
        },
      },
    );
  }

  static Widget getInitialPage() {
    if (!userDataCheckResult.hasUserData) {
      return LoginPage();
    } else if (!userDataCheckResult.userDataComplete) {
      return fillProfile();
    } else {
      return Home_Page();
    }
  }
}
