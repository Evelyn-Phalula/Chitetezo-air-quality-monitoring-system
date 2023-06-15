import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:air_quality/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_data.dart';

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
