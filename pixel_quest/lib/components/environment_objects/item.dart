import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_quest/pixel_quest.dart';

class Item extends SpriteAnimationComponent with HasGameRef<PixelQuest> {
  final String itemName;
  Item({this.itemName = 'JumpHigher', position, size})
      : super(
          position: position,
          size: size,
        );

  final double stepTime = 0.05; // how long each frame of the animation lasts

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$itemName.png'),
      SpriteAnimationData.sequenced(
          amount: 17, stepTime: stepTime, textureSize: Vector2.all(32)),
    );
    return super.onLoad();
  }
}
