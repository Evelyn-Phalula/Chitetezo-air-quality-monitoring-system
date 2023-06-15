import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebSocketChannel channel;
  String _sensorData = '0';

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://192.168.227.90:8765');
    channel.stream.listen((message) {
      setState(() {
        _sensorData = message;
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chitetezo Air Quality',
      debugShowCheckedModeBanner: false, // remove debug label
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chitetezo Air Quality'),
        ),
        body: Center(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Air Level Quality:',
              ),
              Text(
                _sensorData,
                style: Theme.of(context).textTheme.headline4,
              ),Text("ppm"),
            ],
          ),
        ),
      ),
    );
  }



}
