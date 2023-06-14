import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference().child('tokens');
  String? _token;

  @override
  void initState() {
    super.initState();
    _configureFirebaseMessaging();
    _getToken();
  }

  void _configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message in foreground: ${message.notification?.title}');
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(message.notification?.title ?? ''),
          content: Text(message.notification?.body ?? ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Received message in background: ${message.notification?.title}');
  }

  Future<void> _getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    setState(() {
      _token = token;
    });
    _saveTokenToDatabase(token);
  }

  // Future<void> _saveTokenToDatabase(String? token) async {
  //   if (token != null) {
  //     await _database.push().set({'token': token});
  //     print('Token saved to the database');
  //   }
  // }
  Future<void> _saveTokenToDatabase(String? token) async {
    if (token != null) {
      await _database.set({'token': token});
      print('Token saved to the database');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('FCM Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Firebase Cloud Messaging Demo',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text(
                'FCM Token:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                _token ?? 'Token not available',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
