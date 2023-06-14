import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';



class Remotely extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Realtime Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseService firebaseService = FirebaseService();
  String currentValue = '';

  @override
  void initState() {
    super.initState();
    firebaseService.fetchData().listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final List<dynamic> values = data.values.toList();
        if (values.isNotEmpty) {
          setState(() {
            currentValue = values.last.toString();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Realtime Data'),
      ),
      body: Center(
        child: Text(
          currentValue,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Stream<DatabaseEvent> fetchData() {
    return _database.child('random_numbers').orderByKey().limitToLast(1).onValue;
  }
}
