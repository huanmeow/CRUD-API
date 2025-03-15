import 'package:flutter/material.dart';
import 'curd_api.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Shop',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CurdApi(),
    );
  }
}

