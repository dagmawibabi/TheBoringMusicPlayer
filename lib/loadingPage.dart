import 'dart:async';

import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  void loading() {
    Timer(
      Duration(seconds: 3),
      () {
        Navigator.pushReplacementNamed(context, "musicPlayer");
      },
    );
  }

  @override
  void initState() {
    loading();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/launcherIcon.png",
        ),
      ),
    );
  }
}
