
import 'dart:math';
import 'package:engine/models/game_data_model.dart';
import 'package:flame/game.dart';

void randomPosition(GameData gameData, Vector2 point1, Vector2 point2, String player) {
  double minX = min(point1.x, point2.x);
  double minY = min(point1.y, point2.y);
  double maxX = max(point1.x, point2.x);
  double maxY = max(point1.y, point2.y);

  Random random = Random();
  double randomX = minX + random.nextDouble() * (maxX - minX);
  double randomY = minY + random.nextDouble() * (maxY - minY);
  gameData.characters[player]!.position = Vector2(randomX, randomY);
}
