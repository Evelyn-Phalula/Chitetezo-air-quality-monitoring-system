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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("the token is: "+fcmToken!);
  runApp(const MyApp1());
}

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // FirebaseMessaging firebaseMessaging =  FirebaseMessaging.instance;
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  // new FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference().child('tokens');
  String? _token;
 String fc= "hello";
  String _portNumber = ''; // Default port number
  bool _isConnecting = false;
  bool _isConnected = false;
  final _ipAddressController = TextEditingController();
  final _ipAddressFocusNode = FocusNode();

  late TextEditingController _portNumberController;

  //var channel;
  final StreamController<double> _sensorStreamController =
  StreamController<double>.broadcast();

  Stream<double> get _sensorStream => _sensorStreamController.stream;
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    _portNumberController = TextEditingController(text: _portNumber);
    // channel = IOWebSocketChannel.connect('ws://192.168.0.3:8000');
    // channel.stream.listen((message) {
    //   setState(() {
    //     _sensorData = message;
    //     _sensor = double.parse(_sensorData);
    //   });
    // });
    // var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    // var platform = new InitializationSettings(android: android);
    // flutterLocalNotificationsPlugin.initialize(platform);
    // firebaseMessaging.getToken().then((token) {
    //   update(token!);
    // });
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
  Future<void> _saveTokenToDatabase(String? token) async {
    if (token != null) {
      await _database.set({'token': token});
      print('Token saved to the database');
    }
  }
  //
  // update(String token) {
  //   print(token);
  //   DatabaseReference databaseReference = new FirebaseDatabase().reference();
  //   databaseReference.child('Fun-40/fcm-token/${token}').set({"token": token});
  //   fc = token;
  //   setState(() {});
  // }
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
    return Scaffold(
        body: ListView(padding: EdgeInsets.zero, children: [
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
                  title: Text(
                      'Welcome To Chitetezo Air Pollution Monitoring System',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      )),
                  subtitle: Text('Green Air Initiatives',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      )),

                  trailing: const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),

                ),


                const SizedBox(height: 26)
              ],
            ),
          ),
          Container(
            height: 500,
            color: Theme.of(context).primaryColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(200))),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.center,
                      // Align the container to the left
                      child: Container(
                        width: 300,
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 170,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Add your button's action here
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Firebase_data()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.indigo,
                                    // Set the button's background color
                                    onPrimary: Colors.white,
                                    // Set the text color
                                    elevation: 4,
                                    // Set the elevation of the button
                                    padding: EdgeInsets.all(16),
                                    // Set the padding around the button's content
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Set the button's border radius
                                    ),
                                  ),
                                  child: Text(
                                    'Remote Monitoring',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ), // Set the button's label
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
                                    // Add your button's action here
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyApp2()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.indigo,
                                    // Set the button's background color
                                    onPrimary: Colors.white,
                                    // Set the text color
                                    elevation: 4,
                                    // Set the elevation of the button
                                    padding: EdgeInsets.all(16),
                                    // Set the padding around the button's content
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Set the button's border radius
                                    ),
                                  ),
                                  child: Text(
                                    'Onsite Monitoring',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ), // Set the button's label
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
        ]));
  }
}
