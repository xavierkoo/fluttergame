import 'package:flame/components.dart';

// class that represents a collision block with a position and size and whether it is a platform or not
class CollisionBlock extends PositionComponent {
  bool isPlatform;
  CollisionBlock({position, size, this.isPlatform = false})
      : super(position: position, size: size) {
    debugMode = true; // debug mode draws a box around the collision block to show where it is
  }
}
