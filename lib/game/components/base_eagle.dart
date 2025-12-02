import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../game_state.dart';
import '../battle_city_game.dart';

/// База (орёл) с оригинальными спрайтами
class BaseEagle extends SpriteComponent with HasGameRef<BattleCityGame> {
  bool isDestroyed = false;
  
  Sprite? aliveSprite;
  Sprite? destroyedSprite;

  BaseEagle({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(32, 32),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      aliveSprite = await gameRef.loadSprite('sprites/base1.png');
      destroyedSprite = await gameRef.loadSprite('sprites/base2.png');
      sprite = aliveSprite;
    } catch (e) {
      print('Failed to load base sprites: $e');
    }
    
    add(RectangleHitbox(
      size: size,
      position: Vector2.zero(),
    ));
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      super.render(canvas);
    } else {
      // Fallback если спрайты не загрузились
      if (isDestroyed) {
        _drawDestroyedBaseFallback(canvas);
      } else {
        _drawBaseFallback(canvas);
      }
    }
  }

  void _drawBaseFallback(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.black,
    );
    
    final eaglePaint = Paint()..color = const Color(0xFFFFD700);
    
    canvas.drawOval(
      Rect.fromLTWH(6, 10, 20, 18),
      eaglePaint,
    );
    
    canvas.drawOval(
      Rect.fromLTWH(10, 2, 12, 12),
      eaglePaint,
    );
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawDestroyedBaseFallback(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF333333),
    );
    
    final debrisPaint = Paint()..color = const Color(0xFF666666);
    canvas.drawRect(Rect.fromLTWH(2, 2, 8, 6), debrisPaint);
    canvas.drawRect(Rect.fromLTWH(14, 4, 6, 8), debrisPaint);
    canvas.drawRect(Rect.fromLTWH(22, 2, 8, 5), debrisPaint);
  }

  void destroy() {
    isDestroyed = true;
    sprite = destroyedSprite;
  }
}
