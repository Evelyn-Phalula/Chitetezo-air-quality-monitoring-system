import 'dart:convert';
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:badges/badges.dart' as Badge;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:air_quality/notifying.dart';
import 'data.dart';
import 'notifying.dart';

class Firebase_data extends StatelessWidget {
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
  final FirebaseService firebaseService = FirebaseService();
  String currentValue = '';
  late int sensorData = 0;

  @override
  void initState() {
    super.initState();

    super.initState();
    firebaseService.fetchData().listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final List<dynamic> values = data.values.toList();
        if (values.isNotEmpty) {
          setState(() {
            currentValue = values.last.toString();
            sensorData = int.parse(currentValue);
          });
        } else {
          setState(() {
            currentValue = 'No data available';
          });
        }
      } else {
        setState(() {
          currentValue = 'No data available';
        });
      }
    });
    _configureFirebaseMessaging();
  }

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

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Received message in background: ${message.notification?.title}');
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
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chitetezo Air Pollution Monitoring System',
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    // child: const CircleAvatar(
                    //   radius: 20,
                    //   backgroundImage: AssetImage('assets/images/notification_icon1.png'),
                    // ),
                    child: Badge.Badge(
                      badgeContent: Text(
                        notificationCount.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      badgeColor: Colors.red,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            AssetImage('assets/images/notification_icon1.png'),
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
            const SizedBox(height: 39)
          ],
        ),
      ),
      Container(
        height: 530,
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
                Text(
                  "Reduce air pollution!",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 30),
                Text(
                  "Make Earth sustaintable!",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  // Align the container to the left
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(150),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Air Quality Levels",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo),
                          ),
                          SizedBox(height: 40),
                          if (sensorData >= 0 && sensorData <=50)
                            Text(
                              '$currentValue Good Air',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          if (sensorData > 50 && sensorData <= 100)
                            Text(
                              '$currentValue Moderate Air',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber),
                            ),
                          if (sensorData > 100 && sensorData <= 150)
                            Center(
                              child: Text(
                                '$currentValue Unhealthy Air\nfor Sensitive Groups\nPlease take a further action!',
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (sensorData > 150 && sensorData <= 200)
                            Center(
                              child: Text(
                                '$currentValue Unhealthy Air\nPlease take a further action!',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (sensorData > 200 && sensorData <= 300)
                            Text(
                              '$currentValue Very Unhealthy Air\nPlease take a further action!',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurpleAccent),
                              textAlign: TextAlign.center,
                            ),
                          if (sensorData > 300)
                            Center(
                              child: Text(
                                '$currentValue Hazardous Air\nPlease take a further action!',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          SizedBox(height: 45),
                          Text(
                            "Real-Time Updates",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Align(
                  child: Container(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your button's action here
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MyApp3()));
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.indigo,
                        // Set the button's background color
                        onPrimary: Colors.white,
                        // Set the text color
                        elevation: 4,
                        // Set the elevation of the button
                        padding: EdgeInsets.only(top: 12, bottom: 11),
                        // Set the padding around the button's content
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Set the button's border radius
                        ),
                      ),
                      child: Text(
                        'Home',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ), // Set the button's label
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

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Stream<DatabaseEvent> fetchData() {
    return _database
        .child('random_numbers')
        .orderByKey()
        .limitToLast(1)
        .onValue;
  }
}
