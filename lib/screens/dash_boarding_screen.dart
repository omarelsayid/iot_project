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
    _starCountRef = FirebaseDatabase.instance.ref('/test/int');

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

  // Method to send 'true' to the RTDB
  void _sendTrueToRTDB() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('/test/bool');
    ref.set(true);
    Future.delayed(const Duration(seconds: 20), () {
      ref.set(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('IR sensor: $_starCount',
                style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sendTrueToRTDB,
            child: const Text('Send True to RTDB'),
          ),
        ],
      ),
    );
  }
}
