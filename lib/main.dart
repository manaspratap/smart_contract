import 'package:flutter/material.dart';
import 'views/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Contract',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}