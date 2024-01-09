import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_quest/actors/player.dart';

class MainLevel extends World {
  late TiledComponent level; // late means that the variable will be initialized later

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('main_world_0-1.tmx', Vector2.all(16)); // load the level from the file and set the tile size to 16x16
    add(level); // add the level to the world
    add(Player()); // add the player to the world
    return super.onLoad(); // call the super method to finish loading the world
  }
}
