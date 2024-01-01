import 'package:flutter/material.dart';
import 'Home.dart';
import 'engineering.dart';
import'pharmacy.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {

    return const MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'csci410 second project',

      home: WelcomePage(),

    );

  }

}