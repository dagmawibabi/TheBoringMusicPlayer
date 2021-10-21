import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicplayer/loadingPage.dart';
import 'package:musicplayer/musicPlayerPage.dart';

void main() {
  runApp(Main());
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "musicPlayer",
      routes: {
        "/": (context) => LoadingPage(),
        "musicPlayer": (context) => MusicPlayer(),
      },
      theme: ThemeData(
        fontFamily: "Abel",
      ),
    );
  }
}
