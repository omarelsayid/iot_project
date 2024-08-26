import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  DatabaseReference? _starCountRef;
  int _starCount = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize the database reference
    _starCountRef = FirebaseDatabase.instance.ref('/ir_sensor/value');

    // Set up the listener to update the star count when the data changes
    _starCountRef?.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is int) {
        setState(() {
          _starCount = data;
        });
      }
    });
  }

  @override
  void dispose() {
    // Optional: remove the listener when the widget is disposed
    _starCountRef?.onValue.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(
        child: Text('Star Count: $_starCount', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
