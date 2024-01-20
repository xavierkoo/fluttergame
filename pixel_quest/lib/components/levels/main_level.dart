import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_quest/components/actors/player.dart';
import 'package:pixel_quest/components/environment_objects/collision_block.dart';

class MainLevel extends World {
  final String levelName;
  final Player player;
  MainLevel(
      {required this.levelName,
      required this.player}); // constructor that takes in a level name and a player
  late TiledComponent
      level; // late means that the variable will be initialized later
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
        '$levelName.tmx', // load the level from the file
        Vector2.all(
            16)); // load the level from the file and set the tile size to 16x16
    add(level); // add the level to the world

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>(
        'SpawnPoints'); // get the spawn points layer from the level
        
    for (final spawnPoint in spawnPointsLayer!.objects) {
      // loop through all the spawn points
      switch (spawnPoint.type) {
        // check the type of the spawn point
        case 'Player':
          player.position = Vector2(spawnPoint.x, // vector2 is a 2d vector
              spawnPoint.y); // set the player position to the spawn point
          add(player); // add the player to the world
          break;
        default:
      }
    }

    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if(collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        // loop through all the collisions
        switch (collision.class_) {
          // check the type of the collision
          case 'Platform':
            final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true,
            );
            collisionBlocks.add(platform); // add the collision block to the list of collision blocks
            add(platform); // add the collision block to the world
            break;
          default:
            final block = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: false,
            );
            collisionBlocks.add(block); // add the collision block to the list of collision blocks
            add(block); // add the collision block to the world
        }
      }
    }

    player.collisionBlocks = collisionBlocks; // set the player collision blocks to the list of collision blocks
    return super.onLoad(); // call the super method to finish loading the world
  }
}
