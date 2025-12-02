import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../game_state.dart';
import '../battle_city_game.dart';
import 'tank_base.dart';
import 'brick.dart';
import 'player_tank.dart';
import 'enemy_tank.dart';

/// Пуля с оригинальным спрайтом
class Bullet extends SpriteComponent with HasGameRef<BattleCityGame>, CollisionCallbacks {
  final Direction direction;
  final BulletPower power;
  final TankBase owner;
  final BattleCityGame game;
  
  late double speed;
  bool isDestroyed = false;

  Bullet({
    required Vector2 position,
    required this.direction,
    required this.power,
    required this.owner,
    required this.game,
  }) : super(
    position: position,
    size: Vector2(8, 8),
    anchor: Anchor.center,
  ) {
    _setSpeed();
  }

  void _setSpeed() {
    switch (power) {
      case BulletPower.normal:
        speed = GameConstants.bulletSpeedNormal;
        break;
      case BulletPower.fast:
      case BulletPower.super_:
        speed = GameConstants.bulletSpeedFast;
        break;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      sprite = await gameRef.loadSprite('sprites/bullet_down.png');
    } catch (e) {
      print('Failed to load bullet sprite: $e');
    }
    
    // Устанавливаем угол поворота
    switch (direction) {
      case Direction.up:
        angle = 0;
        break;
      case Direction.down:
        angle = 3.14159;
        break;
      case Direction.left:
        angle = -1.5708;
        break;
      case Direction.right:
        angle = 1.5708;
        break;
    }
    
    add(RectangleHitbox(
      size: size,
      isSolid: true,
    ));
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      super.render(canvas);
    } else {
      // Fallback
      final paint = Paint()..color = Colors.white;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 0, 6, 8),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isDestroyed) return;
    
    // Движение пули
    switch (direction) {
      case Direction.up:
        position.y -= speed * dt;
        break;
      case Direction.down:
        position.y += speed * dt;
        break;
      case Direction.left:
        position.x -= speed * dt;
        break;
      case Direction.right:
        position.x += speed * dt;
        break;
    }
    
    // Проверка выхода за границы карты
    if (position.x < 0 || position.x > GameConstants.mapPixelWidth ||
        position.y < 0 || position.y > GameConstants.mapPixelHeight) {
      _explode();
    }
    
    _checkBrickCollisions();
    _checkTankCollisions();
    _checkBaseCollision();
  }

  void _checkBrickCollisions() {
    for (final brick in List.from(game.bricks)) {
      if (_collidesWithBrick(brick)) {
        _handleBrickCollision(brick);
        return;
      }
    }
  }

  bool _collidesWithBrick(Brick brick) {
    final bulletRect = Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x,
      height: size.y,
    );
    
    final brickRect = Rect.fromLTWH(
      brick.position.x,
      brick.position.y,
      GameConstants.cellSize.toDouble(),
      GameConstants.cellSize.toDouble(),
    );
    
    return bulletRect.overlaps(brickRect);
  }

  void _handleBrickCollision(Brick brick) {
    switch (brick.type) {
      case BrickType.wall:
        if (power == BulletPower.super_) {
          game.removeBrick(brick);
        } else {
          brick.damage(direction);
        }
        _explode();
        break;
        
      case BrickType.stone:
        if (power == BulletPower.super_) {
          game.removeBrick(brick);
        }
        _explode();
        break;
        
      case BrickType.water:
      case BrickType.bush:
      case BrickType.ice:
        break;
    }
  }

  void _checkTankCollisions() {
    if (owner is PlayerTank) {
      for (final enemy in List.from(game.enemies)) {
        if (_collidesWithTank(enemy.position)) {
          enemy.takeDamage(this);
          _explode();
          return;
        }
      }
    }
    
    if (owner is EnemyTank) {
      if (game.player1 != null && _collidesWithTank(game.player1!.position)) {
        game.player1!.takeDamage(this);
        _explode();
        return;
      }
      if (game.player2 != null && _collidesWithTank(game.player2!.position)) {
        game.player2!.takeDamage(this);
        _explode();
        return;
      }
    }
  }

  bool _collidesWithTank(Vector2 tankPos) {
    final distance = position.distanceTo(tankPos);
    return distance < GameConstants.tankSize / 2;
  }

  void _checkBaseCollision() {
    if (game.baseEagle == null || game.baseEagle!.isDestroyed) return;
    
    final basePos = game.baseEagle!.position;
    final distance = position.distanceTo(basePos);
    
    if (distance < 16) {
      game.destroyBase();
      _explode();
    }
  }

  void _explode() {
    if (isDestroyed) return;
    isDestroyed = true;
    game.removeBullet(this);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    if (other is Bullet && other.owner != owner) {
      if ((owner is PlayerTank && other.owner is EnemyTank) ||
          (owner is EnemyTank && other.owner is PlayerTank)) {
        _explode();
        other._explode();
      }
    }
  }
}
