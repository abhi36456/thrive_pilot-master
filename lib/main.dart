import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GlobalConfiguration().loadFromAsset("app_settings.json");
    return MaterialApp(
      title: 'Thrive Pilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "HitRoad",
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
