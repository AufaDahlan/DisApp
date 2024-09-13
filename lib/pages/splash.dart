import 'dart:async';

import 'package:flutter/material.dart';
import 'package:realtime/main.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }

  _navigateToNextPage() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp.getInitialPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                // height: 100,
                // width: 100,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Image.asset(
                  'assets/images/nama_app.png',
                  // height: 100,
                  // width: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
