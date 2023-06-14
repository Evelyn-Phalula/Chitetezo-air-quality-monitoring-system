

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Realtime Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Realtime Data'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: firebaseService.fetchData(),
        builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.snapshot.value;
            return Center(
              child: Text(
                data.toString(),
                style: TextStyle(fontSize: 20),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 20),
              ),
            );
          } else {
            return Center(
              child: Text(
                'Loading...',
                style: TextStyle(fontSize: 20),
              ),
            );
          }
        },
      ),
    );
  }
}

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Stream<DatabaseEvent> fetchData() {
    return _database.child('random_numbers').onValue;
  }
}
