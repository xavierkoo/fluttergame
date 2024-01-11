import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_quest/actors/player.dart';

class MainLevel extends World {
  final String levelName;
  MainLevel({required this.levelName}); // constructor that takes in a level name
  late TiledComponent
      level; // late means that the variable will be initialized later

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
        case 'Player': // if the spawn point is a player spawn point
          final player = Player(
              character: 'PinkMan',
              position:
                  Vector2(spawnPoint.x, spawnPoint.y)); // create a new player
          add(player); // add the player to the world
          break;
        default:
      }
    }
    return super.onLoad(); // call the super method to finish loading the world
  }
}
