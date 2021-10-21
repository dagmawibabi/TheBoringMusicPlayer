import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class SoundWave extends StatelessWidget {
  SoundWave({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  final bool isDarkMode;

  final List<List<Color>>? darkModeGradients = [
    [Colors.black, Colors.white],
    [Colors.black, Colors.white],
    [Colors.grey[800]!, Colors.grey[200]!],
    [Colors.grey[600]!, Colors.grey[400]!],
  ];

  final List<List<Color>>? lightModeGradients = [
    [Colors.red, Color(0xEEF44336)],
    [Colors.lightBlueAccent, Colors.blue],
    [Colors.lightGreenAccent, Colors.green],
    [Colors.yellow, Color(0x55FFEB3B)]
  ];
  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        gradients: isDarkMode == true ? darkModeGradients : lightModeGradients,
        durations: [35000, 19440, 10800, 6000],
        heightPercentages: [0.20, 0.23, 0.25, 0.30],
        blur: MaskFilter.blur(BlurStyle.solid, 10),
        gradientBegin: Alignment.bottomLeft,
        gradientEnd: Alignment.topRight,
      ),
      duration: 1000,
      waveAmplitude: 0,
      heightPercentange: 0.25,
      size: Size(
        double.infinity,
        double.infinity,
      ),
    );
  }
}
