import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:air_quality/sensor.dart';
import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'notifying.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // print(fcmToken);
  runApp(const MyApp2());
}

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

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
  String _sensorData = '0';
  double _sensor = 0;
  late String _serverIpAddress;
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
    _configureFirebaseMessaging();
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
          if(notificationCount>0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notificationTitle),
                Text(notificationBody),
              ],
            ),

          if (notificationCount == 0)
            Text('No new notifications'),
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
            const SizedBox(height: 30),
            // ListTile(
            //   contentPadding: const EdgeInsets.symmetric(horizontal: 30),
            //   title: Text('Real-Time Data via WebSockets',
            //       style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            //             color: Colors.white,
            //             fontSize: 30,
            //             fontWeight: FontWeight.bold,
            //           )),
            //   subtitle: Text('Real-Time Updates',
            //       style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //             color: Colors.white70,
            //             fontSize: 20,
            //             fontWeight: FontWeight.normal,
            //           )),
            //   trailing: const CircleAvatar(
            //     radius: 40,
            //     backgroundImage: AssetImage('assets/images/logo.png'),
            //   ),
            // ),

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
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Green Air Initiatives',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      // showDialog(
                      //   context: context,
                      //   builder: (BuildContext context) => AlertDialog(
                      //     title: Text(notificationTitle),
                      //     content: Text(notificationBody),
                      //     actions: [
                      //       TextButton(
                      //         onPressed: () => Navigator.of(context).pop(),
                      //         child: Text('OK'),
                      //       ),
                      //     ],
                      //   ),
                      // );
                    },
                    // child: const CircleAvatar(
                    //   radius: 20,
                    //   backgroundImage: AssetImage('assets/images/notification_icon1.png'),
                    // ),
                    child: Badge(
                      badgeContent: Text(
                        notificationCount.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      badgeColor: Colors.red,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/notification_icon1.png'),
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
            const SizedBox(height: 20)
          ],
        ),
      ),
      Container(
        height: 553,
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
                const SizedBox(height: 0),
                Align(
                  alignment: Alignment.center,
                  // Align the container to the left
                  child: Container(
                    width: 300,
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 250,
                            child: TextFormField(
                              controller: _ipAddressController,
                              focusNode: _ipAddressFocusNode,
                              // onSubmitted: (_) {
                              //   _ipAddressFocusNode.unfocus();
                              // },
                              validator: (String? value) {
                                if (value != null && value.isEmpty) {
                                  // handle the empty value
                                  return "Please enter correct Ip address";
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  _serverIpAddress = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Enter Valid Server IP address',
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.indigo,
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              textAlignVertical: TextAlignVertical.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 250,
                            child: TextFormField(
                              controller: _portNumberController,
                              focusNode: _ipAddressFocusNode,

                              // onSubmitted: (_) {
                              //   _ipAddressFocusNode.unfocus();
                              // },
                              validator: (String? value) {
                                if (value != null && value.isEmpty) {
                                  // handle the empty value
                                  return "Please enter correct port number";
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  _portNumber = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Enter Valid Server Port Number',
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.indigo,
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              textAlignVertical: TextAlignVertical.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            child: ElevatedButton(
                              onPressed: _isConnecting
                                  ? null
                                  : () async {
                                      var serverIpAddress =
                                          _ipAddressController.text;
                                      setState(() {
                                        _isConnecting = true;
                                      });
                                      void _connectToServer() async {
                                        if (_isConnecting ||
                                            _isConnected ||
                                            _serverIpAddress.isEmpty) {
                                          return;
                                        }

                                        setState(() {
                                          _isConnecting = true;
                                        });
                                      }

                                      // Check if the IP address is valid
                                      final internetAddress =
                                          await InternetAddress.tryParse(
                                              _serverIpAddress);
                                      if (internetAddress == null) {
                                        // Show an error message
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Invalid IP address'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        setState(() {
                                          _isConnecting = false;
                                        });
                                        return;
                                      }

                                      // Check if the port number is valid
                                      if (_portNumber == null ||
                                          _portNumber.isEmpty ||
                                          int.tryParse(_portNumber) == null) {
                                        // Show an error message
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Invalid port number'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        setState(() {
                                          _isConnecting = false;
                                        });
                                        return;
                                      }
                                      if (_serverIpAddress.isNotEmpty &&
                                          _portNumber.isNotEmpty) {
                                        try {
                                          // Check if the IP address is valid
                                          if (_serverIpAddress == null ||
                                              _serverIpAddress.isEmpty) {
                                            throw 'Please enter a valid IP address';
                                          }
                                          if (_portNumber == null &&
                                              _portNumber.isEmpty &&
                                              _serverIpAddress == null &&
                                              _serverIpAddress.isEmpty) {
                                            throw 'Please enter a valid IP address and port number';
                                          }
                                          // Check if the port number is valid
                                          if (_portNumber == null ||
                                              _portNumber.isEmpty) {
                                            throw 'Please enter a valid port number';
                                          }
                                          int port = int.parse(_portNumber);
                                          if (port == null ||
                                              port < 0 ||
                                              port > 65535) {
                                            throw 'Please enter a valid port number';
                                          }

                                          channel = IOWebSocketChannel.connect(
                                              'ws://$serverIpAddress:$_portNumber');

                                          // Connection successful, do something...
                                          // channel.stream.listen((message) {
                                          //   _sensorData = message;
                                          //   _sensor = double.parse(_sensorData);
                                          // });
                                          channel.stream.listen((data) {
                                            if (data != null) {
                                              // Parse the data as a double value
                                              final double? sensorValue =
                                                  double.parse(data);

                                              if (sensorValue != null) {
                                                // Emit the sensor value to the stream
                                                _sensorStreamController
                                                    .add(sensorValue);
                                              }
                                            }
                                          }, onError: (error) {
                                            // Handle errors
                                          }, onDone: () {
                                            // Handle done
                                          });
                                          setState(() {
                                            _isConnecting = false;
                                            _isConnected = true;
                                          });
                                          // Show a success message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Connected to server successfully.'),
                                            ),
                                          );
                                        } catch (e) {
                                          // Connection failed, show an error message...
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Failed to connect to server: $e'),
                                            ),
                                          );
                                        }
                                        setState(() {
                                          _isConnecting = false;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please enter server IP address and port number.'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                              child: _isConnecting
                                  ? CircularProgressIndicator()
                                  : Text('Connect to server'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: 230,
                          height: 230,
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
                              children: [
                                SizedBox(height: 28),
                                const Text(
                                  'Air Quality Levels',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 50),
                                StreamBuilder<double>(
                                  stream: _sensorStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      // Use the latest sensor value
                                      final double? sensorValue = snapshot.data;
                                      if (sensorValue! >= 0 &&
                                          sensorValue! <= 50) {
                                        return Text(
                                          '$sensorValue  Good Air',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      } else if (sensorValue >= 51 &&
                                          sensorValue <= 100) {
                                        return Text(
                                          '$sensorValue Moderate Air',
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      } else if (sensorValue >= 101 &&
                                          sensorValue <= 200) {
                                        return Text(
                                          '$sensorValue Unhealthy Air',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      } else if (sensorValue >= 201 &&
                                          sensorValue <= 300) {
                                        return Text(
                                            '$sensorValue Very Unhealthy Air',
                                            style: const TextStyle(
                                              color: Colors.purple,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ));
                                      } else {
                                        return Text(
                                          '$sensorValue  Hazardous Air',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else
                                      return Text(
                                        'Waiting for data...',
                                        style: TextStyle(fontSize: 18),
                                      );
                                  },
                                ),
                                SizedBox(height: 50),
                                const Text(
                                  "Updates Automatically",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                // Add your button's action here
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyApp3()));
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
                                      4), // Set the button's border radius
                                ),
                              ),
                              child: Text(
                                'Home',
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
