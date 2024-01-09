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

// sprite animation group component vs sprite component
// is that sprite animation group component can have multiple animations
// and can switch between them while sprite component can only have one animation
class Player extends SpriteAnimationGroupComponent with HasGameRef<PixelQuest> {
  late final SpriteAnimation idleAnimation;
  final double stepTime = 0.05; // how long each frame of the animation lasts

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations(); // _ means that this method is private
    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache('MainCharacters/PinkMan/Idle (32x32).png'),
      SpriteAnimationData.sequenced(
          amount: 11, // how many frames are in the animation (from image file)
          stepTime: stepTime, 
          textureSize: Vector2.all(32) // size of each frame in the animation
      )
    );

    // list of all animations that the player can have so that we can switch between them
    animations = {
      PlayerState.idle: idleAnimation,
    };

    current = PlayerState.idle; // set the current animation to idle
  }
}
