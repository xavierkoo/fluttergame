import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_quest/pixel_quest.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // wait for flutter to initialize before running the game
  Flame.device.fullScreen(); // make the game fullscreen
  Flame.device.setLandscape(); // set the game to landscape mode

  PixelQuest game = PixelQuest();
  runApp(GameWidget(game: kDebugMode ? PixelQuest() : game)); // if in debug mode, run the game in a widget
}
