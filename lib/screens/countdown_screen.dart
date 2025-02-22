import 'package:flutter/material.dart';

class CountdownScreen extends StatelessWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Countdown'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Countdown Page',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
