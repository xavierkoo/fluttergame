import 'dart:async';

import 'package:flame/components.dart';
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

enum PlayerDirection {
  left,
  right,
  none,
}

// sprite animation group component vs sprite component
// is that sprite animation group component can have multiple animations
// and can switch between them while sprite component can only have one animation
class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelQuest> {
  String character;
  Player({position, required this.character})
      : super(
            position:
                position); // constructor that takes in a character name, super position means that the position is passed to the parent class

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05; // how long each frame of the animation lasts

  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations(); // _ means that this method is private
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // dt stands for delta time, the time between each frame e.g. 0.016 means 16 milliseconds used to make sure that the game runs at the same speed on all devices
    _updatePlayerMovement(dt);
    super.update(dt);
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
    double dirX = 0.0; // direction of the player on the x axis, +1 is right, -1 is left
    switch(playerDirection) {
      case PlayerDirection.left:
        if(isFacingRight) {
          isFacingRight = false;
          flipHorizontallyAroundCenter();
        }
        current = PlayerState.running; // set the current animation to running
        dirX -= moveSpeed; // move the player left by the move speed
        break;
      case PlayerDirection.right:
        if(!isFacingRight) {
          isFacingRight = true;
          flipHorizontallyAroundCenter();
        }
        current = PlayerState.running; // set the current animation to running
        dirX += moveSpeed; // move the player right by the move speed
        break;
      default:
        current = PlayerState.idle; // set the current animation to idle
        break;
    }

    velocity = Vector2(dirX, 0.0); // set the velocity of the player to the new x direction
    position += velocity * dt; // move the player by the velocity, dt is used to make sure that the player moves at the same speed on all devices
  }
}
