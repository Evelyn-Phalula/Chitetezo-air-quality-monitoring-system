import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:air_quality/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/widgets.dart';
import 'firebase_data.dart';
import 'package:badges/badges.dart';
//main method
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  //initializing firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //checking the token that is used to trigger functions on firebase
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("the token is: $fcmToken");
  runApp(const MyApp3());
}

//stateless widget
class MyApp3 extends StatelessWidget {
  const MyApp3({Key? key}) : super(key: key);

  @override
  //Title section
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chitete Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(),
    );
  }
}
//stateful widget extended to use some classess
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
//class contain all the data and designs
class _MyHomePageState extends State<MyHomePage> {
  //connecting to firebase and initializaing varios variables
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _database =
      FirebaseDatabase.instance.reference().child('tokens');
  String? _token;
  String fc = "hello";
  String _portNumber = ''; // Default port number
  bool _isConnecting = false;
  bool _isConnected = false;
  final _ipAddressController = TextEditingController();
  final _ipAddressFocusNode = FocusNode();

  late TextEditingController _portNumberController;

  final StreamController<double> _sensorStreamController =
      StreamController<double>.broadcast();

  Stream<double> get _sensorStream => _sensorStreamController.stream;
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    _portNumberController = TextEditingController(text: _portNumber);
    _configureFirebaseMessaging();
    _getToken();
  }

  //getting notifications from the firebase
  RemoteMessage? receivedMes;
  late String notificationTitle = '';
  late String notificationBody = '';
  int notificationCount = 0;
  void _configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message in foreground: ${message.notification?.title}');
      receivedMes = message;
      setState(() {
        notificationTitle = receivedMes?.notification?.title ?? '';
        notificationBody = receivedMes?.notification?.body ?? '';
        notificationCount++;
      });
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  //Handles background notifications
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Received message in background: ${message.notification?.title}');
  }
  // void navigateToApp() {
  //   // Call this function when the user clicks on the notification and navigates to the app
  //   setState(() {
  //     notificationCount = 0; // Set notificationCount to 0
  //   });
  // }








  Future<void> _getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    setState(() {
      _token = token;
    });
    _saveTokenToDatabase(token);
  }

  Future<void> _saveTokenToDatabase(String? token) async {
    if (token != null) {
      await _database.set({'token': token});
      print('Token saved to the database');
    }
  }

  @override
  void dispose() {
    _sensorStreamController.close();
    if (_isConnected) {
      channel.sink.close();
    }
    _portNumberController.dispose();
    _ipAddressController.dispose();
    _ipAddressFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: Colors.indigo, // Set the desired background color
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (notificationCount > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notificationTitle),
                Text(notificationBody),
              ],
            ),
          if (notificationCount == 0) Text('No new notifications'),
        ],
      ),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white, // Set the label color to white
        onPressed: () {
          if (notificationCount > 0) {
            setState(() {
              notificationCount--;
            });
          }
        },
      ),
    );

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome To Chitetezo Air Pollution Monitoring System',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Green Air Initiatives',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: Badge(
                          badgeContent: Text(
                            notificationCount.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          badgeColor: Colors.red,
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                                'assets/images/notification_icon1.png'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 56),
              ],
            ),
          ),
          Container(
            height: 400,

            color: Theme.of(context).primaryColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(200),
                ),
              ),

              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 300,
                        child: Column(
                          children: <Widget>[
                            Text(
                              "To breathe clean!",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "You have to go green!",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            const SizedBox(height: 50),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 170,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Firebase_data(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.indigo,
                                    onPrimary: Colors.white,
                                    elevation: 4,
                                    padding: EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Remote Monitoring',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 170,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyApp2(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.indigo,
                                    onPrimary: Colors.white,
                                    elevation: 4,
                                    padding: EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Onsite Monitoring',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
