import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_quest/levels/main_level.dart';
import 'package:pixel_quest/constants/colors.dart';

class PixelQuest extends FlameGame {
  @override
  Color backgroundColor() => const Color(ColorConstants.mainWorldSky);
  late final CameraComponent
      cam; // late means that the variable will be initialized later

  @override
  final world = MainLevel();

  @override
  FutureOr<void> onLoad() async {

    // load all images into cache before the game starts, if too many images are 
    // loaded it will slow down the start of the game so modify this to only load the images you need later
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640,
        height: 360); // create a camera with a fixed resolution of 640x360

    cam.viewfinder.anchor = Anchor
        .topLeft; // set the anchor of the viewfinder to the top left corner of the screen

    addAll([cam, world]);

    return super.onLoad();
  }
}
