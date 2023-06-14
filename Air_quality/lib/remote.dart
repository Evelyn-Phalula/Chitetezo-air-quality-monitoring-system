import 'package:flutter/material.dart';

class Remote extends StatelessWidget {
  const Remote({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
      ),
      body: Center(
        child: Text("hi"),
      ),
    );
  }
}
