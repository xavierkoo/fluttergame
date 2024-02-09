import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_quest/components/environment_objects/collision_block.dart';
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
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  final double stepTime = 0.05; // how long each frame of the animation lasts

  final double _gravity = 15;
  final double _jumpForce = 330;
  final double _terminalVelocity = 300;
  double horizontalMovement =
      0; // 0 means not moving, -1 means moving left, 1 means moving right
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations(); // _ means that this method is private
    debugMode = true;
    return super.onLoad();
  }

  // update sequence: update player movement -> update player state -> check horizontal collisions -> apply gravity
  // check horizontal collisions and apply gravity is after update player state because we want to check collisions and apply gravity after the player has moved
  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(
        dt); // dt stands for delta time, the time between each frame e.g. 0.016 means 16 milliseconds used to make sure that the game runs at the same speed on all devices
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
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

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);

    // list of all animations that the player can have so that we can switch between them
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
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

  void _playerJump(double dt) {
    velocity.y =
        -_jumpForce; // set the velocity to the jump force (negative because upwards)
    position.y += velocity.y * dt; // move the player by the velocity
    isOnGround = false;
    hasJumped = false;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(
          dt); // player can only jump if they are on the ground to prevent double jumping
    }

    velocity.x = horizontalMovement *
        moveSpeed; // set the velocity to the horizontal movement times the move speed
    position.x += velocity.x *
        dt; // move the player by the velocity, dt is used to make sure that the player moves at the same speed on all devices
  }

  // update the player state based on the player velocity and direction
  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) { // if the player is moving left and facing right
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) { // if the player is moving right and facing left
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    // Check if falling or jumping
    if (!isOnGround) {
      if (velocity.y > 0) {
        playerState = PlayerState.falling;
      } else if (velocity.y < 0) {
        playerState = PlayerState.jumping;
      }
    }

    current = playerState;
  }

  void _applyGravity(double dt) {
    velocity.y +=
        _gravity; // downwards velocity increases by gravity (acceleration)
    velocity.y = velocity.y.clamp(-_jumpForce,
        _terminalVelocity); // clamp the velocity between the jump force and the terminal velocity so that the player doesn't fall too fast or jump too high
    position.y += velocity.y * dt; // move the player by the velocity
  }

  // TODO: add collision with items which is different from collision with blocks
  void _checkHorizontalCollisions() {
    final playerBounds = toRect(); // get the player bounds as a rectangle

    for (final block in collisionBlocks) {
      if (playerBounds.overlaps(block.toRect())) {
        // check if the player is colliding with the block
        if (horizontalMovement < 0) {
          // if the player is moving left
          position.x = block.toRect().right +
              playerBounds
                  .width; // set the player position to the right side of the block
        } else if (horizontalMovement > 0) {
          // if the player is moving right
          position.x = block.toRect().left -
              playerBounds
                  .width; // set the player position to the left side of the block
        }
      }
    }
  }

  // TODO: add collision with items which is different from collision with blocks
  void _checkVerticalCollisions() {
    final playerBounds = toRect(); // get the player bounds as a rectangle

    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (playerBounds.overlaps(block.toRect())) {
          // check if the player is colliding with the block
          if (velocity.y > 0) {
            // if the player is moving down
            position.y = block.toRect().top -
                playerBounds
                    .height; // set the player position to the top of the block
            isOnGround = true;
          } else if (velocity.y < 0) {
            // if the player is moving up
            position.y = block.toRect().bottom +
                playerBounds
                    .height; // set the player position to the bottom of the block
          }
        }
      } else {
        if (playerBounds.overlaps(block.toRect())) {
          // allow the player to jump through platforms only if they are moving down
          if (velocity.y > 0) {
            // if the player is moving down
            position.y = block.toRect().top -
                playerBounds
                    .height; // set the player position to the top of the block
            isOnGround = true;
          }
        }
      }
    }
  }
}
