import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_quest/pixel_quest.dart';

// enum is a special type of class that can only have a few values, used to represent a state
enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  attacking,
  hurt,
  dead,
}

// sprite animation group component vs sprite component
// is that sprite animation group component can have multiple animations
// and can switch between them while sprite component can only have one animation
class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelQuest>, KeyboardHandler {
  // keyboard handler allows the player to be controlled by the keyboard
  String character;
  Player({position, this.character = 'VirtualGuy'})
      : super(
            position:
                position); // constructor that takes in a character name, super position means that the position is passed to the parent class

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05; // how long each frame of the animation lasts

  double horizontalMovement =
      0; // 0 means not moving, -1 means moving left, 1 means moving right
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations(); // _ means that this method is private
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // dt stands for delta time, the time between each frame e.g. 0.016 means 16 milliseconds used to make sure that the game runs at the same speed on all devices
    _updatePlayerState();
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
            keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
            keysPressed.contains(LogicalKeyboardKey.keyD);

    horizontalMovement +=
        isLeftKeyPressed ? -1 : 0; // if left key is pressed then move left
    horizontalMovement +=
        isRightKeyPressed ? 1 : 0; // if right key is pressed then move right

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);

    // list of all animations that the player can have so that we can switch between them
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('MainCharacters/$character/$state (32x32).png'),
        SpriteAnimationData.sequenced(
            amount:
                amount, // how many frames are in the animation (from image file)
            stepTime: stepTime,
            textureSize: Vector2.all(32) // size of each frame in the animation
            ));
  }

  void _updatePlayerMovement(double dt) {
    velocity.x = horizontalMovement *
        moveSpeed; // set the velocity to the horizontal movement times the move speed
    position.x += velocity.x *
        dt; // move the player by the velocity, dt is used to make sure that the player moves at the same speed on all devices
  }
  
  void _updatePlayerState() {
    if (horizontalMovement == 0) {
      current = PlayerState.idle;
    } else {
      current = PlayerState.running;
    }
  }
}
