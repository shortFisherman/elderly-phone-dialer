import 'package:flutter/material.dart';

class PhoneCallApp extends StatelessWidget {
  const PhoneCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Call',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Phone Call 2.0'),
        ),
      ),
    );
  }
}
