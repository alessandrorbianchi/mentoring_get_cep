// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'src/view/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Mentoring - Get CEP.',
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color.fromRGBO(38, 63, 47, 1),
        ),
      ),
      home: const HomePage(),
    );
  }
}
