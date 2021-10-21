import 'dart:async';
import 'dart:math';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicplayer/songSamples.dart';
import 'package:musicplayer/soundWaveWidget.dart';
import 'package:web_scraper/web_scraper.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer>
    with TickerProviderStateMixin {
  Random random = Random();
  int currentSong = 0;
  bool isMusicPlaying = false;
  late String currentAlbumArt = "assets/images/albumArts/albumArt16.jpg";
  late AudioPlayer player;
  late double durationOfMusicFile = 100.0;
  double currenSeekPosition = 0;
  String durationOfMusicFileHHMMSS = "0:00";
  String currenSeekPositionHHMMSS = "0:00";
  static bool isDarkMode = false;
  Widget soundWave = Container();
  late TabController tabBarController;

  /*void webScrapeForLyrics() async {
    final webScraper = WebScraper('https://webscraper.io');

    if (await webScraper
        .loadFullURL("https://www.google.com/search?q=daylight+lyrics")) {
      String elements = webScraper.getElement('div.title > a.title', "attribs");
      print("======================================================");
      print(elements);
      print("======================================================");
    }
  }*/

  List playlist = [];
  void fetchSongSamples() {
    playlist = SongSamples().playlist;
  }

  void playerInit() async {
    player = AudioPlayer();
  }

  void stopPlayer() async {
    await player.stop();
  }

  void playOrPause() {
    if (isMusicPlaying == true) {
      player.pause();
      isMusicPlaying = false;
    } else if (isMusicPlaying == false) {
      player.play();
      isMusicPlaying = true;
    }
    scrollLyrics(isMusicPlaying);
    setState(() {});
  }

  int playerSpeed = 1;
  void loadSong() async {
    stopPlayer();
    await player.setAsset(playlist[currentSong]["link"]);
    //playerSpeed = player.duration!.inSeconds;
    playerSpeed = player.preferredPeakBitRate as int;
    durationOfMusicFile = player.duration!.inSeconds.toDouble();
    durationOfMusicFileHHMMSS =
        (durationOfMusicFile.ceil() / 60).floor().toString() +
            ":" +
            (durationOfMusicFile.ceil() % 60).toString();
    currenSeekPosition = 0;
  }

  void nextSong() async {
    currentSong++;
    if (currentSong == playlist.length) {
      currentSong = 0;
    }
    loadSong();
    isMusicPlaying = false;
    playOrPause();
  }

  void seekMusic(currenSeekPosition) {
    player.seek(Duration(seconds: currenSeekPosition.ceil()));
  }

  void previousSong() {
    currentSong--;
    if (currentSong < 0) {
      currentSong = playlist.length - 1;
    }
    loadSong();
    playOrPause();
  }

  Color scaffoldBGColor = Color.fromRGBO(200, 200, 200, 1.0);
  Color playerBGColor = Color.fromRGBO(220, 220, 220, 0.8);
  Color lyricsBGColor = Color.fromRGBO(220, 220, 220, 0.8);
  Color textColor = Colors.black;
  Brightness statusBarIconBrightness = Brightness.light;
  void darkMode() {
    if (isDarkMode == false) {
      scaffoldBGColor = Color.fromRGBO(200, 200, 200, 1.0);
      playerBGColor = Color.fromRGBO(220, 220, 220, 1.0);
      lyricsBGColor = Color.fromRGBO(230, 230, 230, 1.0);
      statusBarIconBrightness = Brightness.dark;
      textColor = Colors.black;
    } else if (isDarkMode == true) {
      scaffoldBGColor = Color.fromRGBO(50, 50, 50, 1.0);
      playerBGColor = Color.fromRGBO(77, 77, 77, 1.0);
      lyricsBGColor = Color.fromRGBO(87, 87, 87, 1.0);
      textColor = Color.fromRGBO(180, 180, 180, 1.0);
      statusBarIconBrightness = Brightness.light;
    }
    soundWave = SoundWave(isDarkMode: isDarkMode);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: scaffoldBGColor, //Color(0xffdcbce1),
        statusBarIconBrightness: statusBarIconBrightness,
      ),
    );
    setState(() {});
  }

  ScrollController _scrollController = ScrollController();
  void scrollLyrics(isScrollLyrics) {
    if (isScrollLyrics == true) {
      double maxExtent = _scrollController.position.maxScrollExtent;
      double distanceDifference = maxExtent - _scrollController.offset;
      double durationDouble = (distanceDifference + 150) / (playerSpeed * 10);
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(seconds: durationDouble.toInt()),
          curve: Curves.linear);
    } else {
      _scrollController.animateTo(_scrollController.offset,
          duration: Duration(seconds: 1), curve: Curves.linear);
    }
  }

  @override
  void initState() {
    tabBarController = TabController(
      length: 2,
      vsync: this,
    );
    //webScrapeForLyrics();
    fetchSongSamples();
    playerInit();
    loadSong();
    darkMode();
    super.initState();
  }

  GlobalKey<FlipCardState> playerFlipController = GlobalKey<FlipCardState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBGColor,
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              children: [
                SizedBox(height: 60.0),
                // Music Player and Options
                FlipCard(
                  key: playerFlipController,
                  // Music Player
                  front: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: playerBGColor,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black54
                                : Colors.grey[600]!.withOpacity(0.7),
                            offset: Offset(4.0, 4.0),
                            blurRadius: 15.0,
                            spreadRadius: 1.0,
                          ),
                          /*BoxShadow(
                            color: Colors.grey[300]!,
                            offset: Offset(2.0, 6.0),
                            blurRadius: 10.0,
                            spreadRadius: -100.0,
                          ),*/
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Artist, Time and Date, Dark Mode and Settings
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Artist
                              Text(
                                playlist[currentSong]["artist"],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Settings
                              /*IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.flip,
                                ),
                              ),*/
                              // Time and Date
                              /*Text(
                                "Aug 1 - 07:51 PM ",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),*/
                            ],
                          ),
                          SizedBox(height: 10.0),
                          // Album Art and Lyrics
                          FlipCard(
                            direction: FlipDirection.HORIZONTAL,
                            // Album Art
                            front: Container(
                              width: 350.0,
                              height: 350.0,
                              decoration: BoxDecoration(
                                color: lyricsBGColor,
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    width: 350.0,
                                    height: 350.0,
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Image.asset(
                                        playlist[currentSong]["albumArt"],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    child: isMusicPlaying
                                        ? soundWave
                                        : Container(),
                                    width: 360.0,
                                    height: 10.0,
                                  ),
                                ],
                              ),
                            ),
                            // Lyrics
                            back: Container(
                              width: 350.0,
                              height: 350.0,
                              decoration: BoxDecoration(
                                color: lyricsBGColor,
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: 10.0,
                                        left: 12.0,
                                        right: 8.0,
                                        bottom: 8.0),
                                    child: ListView(
                                      controller: _scrollController,
                                      children: [
                                        SizedBox(height: 100.0),
                                        Center(
                                          child: Text(
                                            playlist[currentSong]["lyrics"],
                                            style: TextStyle(
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 100.0),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    child: soundWave,
                                    width: 360.0,
                                    height: 10.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 14.0),
                          // Song Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                playlist[currentSong]["title"],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.0),
                          // Seeker
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      currenSeekPositionHHMMSS,
                                      style: TextStyle(
                                        color: textColor,
                                      ),
                                    ),
                                    Text(
                                      durationOfMusicFileHHMMSS,
                                      style: TextStyle(
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Slider(
                                value: currenSeekPosition,
                                onChanged: (double value) {
                                  currenSeekPosition = value;
                                  seekMusic(currenSeekPosition);
                                  setState(() {});
                                },
                                min: 0.0,
                                max: durationOfMusicFile,
                                label: durationOfMusicFile.toString(),
                                activeColor: Color(0xff142536),
                                inactiveColor: Color(0x22111111),
                              ),
                            ],
                          ),
                          // Controlls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Repeat Button
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.repeat,
                                  size: 26.0,
                                  color: textColor,
                                ),
                              ),
                              // Fast Rewind Button
                              IconButton(
                                onPressed: () {
                                  previousSong();
                                },
                                icon: Icon(
                                  Icons.fast_rewind_rounded,
                                  size: 36.0,
                                  color: textColor,
                                ),
                              ),
                              // Pause and Play Button
                              IconButton(
                                onPressed: () {
                                  playOrPause();
                                },
                                icon: Icon(
                                  isMusicPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 36.0,
                                  color: textColor,
                                ),
                              ),
                              // Fast Forward Button
                              IconButton(
                                onPressed: () {
                                  nextSong();
                                },
                                icon: Icon(
                                  Icons.fast_forward_rounded,
                                  size: 36.0,
                                  color: textColor,
                                ),
                              ),
                              // Shuffle Button
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.shuffle,
                                  size: 26.0,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  ),
                  // Options
                  back: Container(
                    height: 500.0,
                    width: 400.0,
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: playerBGColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: tabBarController,
                          indicatorColor: textColor,
                          labelColor: textColor,
                          tabs: [
                            Tab(
                              icon: Icon(Icons.settings),
                              text: 'Settings',
                            ),
                            Tab(
                              icon: Icon(Icons.info_outline),
                              text: 'About',
                            ),
                          ],
                        ),
                        ListView(
                          shrinkWrap: true,
                          children: [
                            SizedBox(height: 20.0),
                            SizedBox(
                              height: 300.0,
                              width: 400.0,
                              child: TabBarView(
                                controller: tabBarController,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isDarkMode
                                                ? Icons.light_mode
                                                : Icons.dark_mode,
                                            color: textColor,
                                          ),
                                          SizedBox(width: 10.0),
                                          Text(
                                            "Dark Mode",
                                            style: TextStyle(
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      CupertinoSwitch(
                                          value: isDarkMode,
                                          activeColor: textColor,
                                          onChanged: (value) {
                                            isDarkMode = !isDarkMode;
                                            darkMode();
                                          })
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Made with " +
                                            (isDarkMode ? "🤍" : "🖤") +
                                            " by Dream Intelligence!",
                                        style: TextStyle(color: textColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 60.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
