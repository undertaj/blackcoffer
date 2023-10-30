import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:blackcoffer/phone.dart';
import 'firebase_options.dart';
import 'homepage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );




  //runApp(MyApp());
  runApp(MaterialApp(
    initialRoute: 'phone',
    debugShowCheckedModeBanner: false,
    routes: {
      'phone': (context) => const MyPhone(),
      // 'verify': (context) => const MyVerify(),
      'home': (context) =>  HomePage(),
    },
  ));
}

