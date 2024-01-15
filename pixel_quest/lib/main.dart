import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_quest/pixel_quest.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wait for flutter to initialize before running the game
  await Flame.device.fullScreen(); // make the game fullscreen, await is to allow the game to set the screen to fullscreen before running the game
  await Flame.device.setLandscape(); // set the game to landscape mode, await is to allow the game to set the screen to landscape mode before running the game

  PixelQuest game = PixelQuest();
  runApp(GameWidget(game: kDebugMode ? PixelQuest() : game)); // if in debug mode, run the game in a widget
}
