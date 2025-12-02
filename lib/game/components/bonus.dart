import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../game_state.dart';
import '../battle_city_game.dart';

/// Бонусный предмет с оригинальными спрайтами
class BonusItem extends SpriteComponent with HasGameRef<BattleCityGame>, CollisionCallbacks {
  final BonusType type;
  final BattleCityGame game;
  
  double _blinkTimer = 0;
  bool _visible = true;
  double _lifeTime = 15.0;

  BonusItem({
    required Vector2 position,
    required this.type,
    required this.game,
  }) : super(
    position: position,
    size: Vector2(28, 28),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    await _loadSprite();
    
    add(RectangleHitbox(
      size: size,
      isSolid: false,
    ));
  }

  Future<void> _loadSprite() async {
    String spriteName = _getSpriteName();
    
    try {
      sprite = await gameRef.loadSprite('sprites/$spriteName.png');
    } catch (e) {
      print('Failed to load bonus sprite: $e');
    }
  }

  String _getSpriteName() {
    switch (type) {
      case BonusType.grenade:
        return 'bonus_grenade';
      case BonusType.helmet:
        return 'bonus_helmet';
      case BonusType.clock:
        return 'bonus_clock';
      case BonusType.shovel:
        return 'bonus_shovel';
      case BonusType.tank:
        return 'bonus_tank';
      case BonusType.star:
        return 'bonus_star';
      case BonusType.gun:
        return 'bonus_gun';
      case BonusType.boat:
        return 'bonus_boat';
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Мигание
    _blinkTimer += dt;
    if (_blinkTimer >= 0.15) {
      _blinkTimer = 0;
      _visible = !_visible;
    }
    
    // Таймер жизни
    _lifeTime -= dt;
    if (_lifeTime <= 0) {
      game.removeBonus(this);
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_visible) return;
    
    if (sprite != null) {
      super.render(canvas);
    } else {
      // Fallback
      _renderFallback(canvas);
    }
  }

  void _renderFallback(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.grey.shade800,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // Иконка типа
    final icon = _getIconForType();
    final textPainter = TextPainter(
      text: TextSpan(
        text: icon,
        style: const TextStyle(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }

  String _getIconForType() {
    switch (type) {
      case BonusType.grenade:
        return '💣';
      case BonusType.helmet:
        return '🪖';
      case BonusType.clock:
        return '⏰';
      case BonusType.shovel:
        return '🔧';
      case BonusType.tank:
        return '🚗';
      case BonusType.star:
        return '⭐';
      case BonusType.gun:
        return '🔫';
      case BonusType.boat:
        return '⛵';
    }
  }
}
