import 'package:flutter/material.dart';
import 'package:uygulama_odevi/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),   
    );
  }
}