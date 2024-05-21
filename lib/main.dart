import 'package:flutter/material.dart';
import 'anasayfa.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          const AnaSayfa(), // Ana ekran olarak anaSayfa widget'ını kullanıyoruz
    );
  }
}