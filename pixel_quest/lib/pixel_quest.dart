import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_quest/components/levels/main_level.dart';
import 'package:pixel_quest/components/actors/player.dart';

class PixelQuest extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  // has keyboard handler components allows the game to handle keyboard input
  late final CameraComponent
      cam; // late means that the variable will be initialized later
  Player player = Player(character: 'VirtualGuy');
  late JoystickComponent joystick;
  bool showJoystick =
      false; // to toggle the joystick on and off for mobile vs desktop

  @override
  FutureOr<void> onLoad() async {
    // load all images into cache before the game starts, if too many images are
    // loaded it will slow down the start of the game so modify this to only load the images you need later
    await images.loadAllImages();

    final world = MainLevel(levelName: 'main_world_0-2', player: player);

    // load the parallax background
    final parallaxBackground = await loadParallaxComponent([
      ParallaxImageData('Background/Clouds/Clouds1/1.png'),
      ParallaxImageData('Background/Clouds/Clouds1/2.png'),
      ParallaxImageData('Background/Clouds/Clouds1/4.png'),
    ],
        baseVelocity: Vector2(
            2, 0), // base velocity is the velocity that the background moves at
        velocityMultiplierDelta: Vector2(1.6,
            1.0), // velocity multiplier delta is how much the velocity changes by each time the player moves
        fill: LayerFill.width,
        alignment: Alignment.center);
    add(parallaxBackground);

    cam = CameraComponent.withFixedResolution(
        world: world,
        width: 640,
        height: 360); // create a camera with a fixed resolution of 640x360

    cam.viewfinder.anchor = Anchor
        .topLeft; // set the anchor of the viewfinder to the top left corner of the screen

    addAll([cam, world]);

    if (showJoystick) {
      addJoystick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png')),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    add(joystick);
  }

  // joystick callbacks to update the player direction based on the joystick direction
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1; // move the player left
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1; // move the player right
        break;
      default:
        player.horizontalMovement = 0; // don't move the player
        break;
    }
  }
}
