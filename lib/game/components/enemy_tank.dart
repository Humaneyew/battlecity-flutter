import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../game_state.dart';
import '../battle_city_game.dart';
import 'tank_base.dart';
import 'bullet.dart';
import 'brick.dart';

/// Танк врага с оригинальными спрайтами и ИИ
class EnemyTank extends TankBase {
  final EnemyType type;
  final BattleCityGame game;
  
  bool hasItem = false;
  
  double _moveTimer = 0;
  double _keepMoveTime = 0;
  double _fireTimer = 0;
  double _fireDelay = 2.0;
  
  final Random _random = Random();
  
  bool _isInitializing = true;
  double _initTimer = 1.5;
  
  SpriteAnimation? spawnAnimation;

  EnemyTank({
    required Vector2 position,
    required this.type,
    required this.game,
  }) : super(position: position) {
    _initializeByType();
  }

  void _initializeByType() {
    switch (type) {
      case EnemyType.typeA:
        armour = _random.nextInt(2);
        speed = GameConstants.enemySpeedNormal;
        break;
      case EnemyType.typeB:
        armour = _random.nextInt(2);
        speed = GameConstants.enemySpeedFast;
        break;
      case EnemyType.typeC:
        armour = _random.nextInt(4);
        bulletPower = BulletPower.fast;
        speed = GameConstants.enemySpeedNormal;
        break;
      case EnemyType.typeD:
        armour = _random.nextInt(3) + 1;
        bulletPower = BulletPower.fast;
        speed = GameConstants.enemySpeedNormal - 10;
        break;
    }
    
    if (_random.nextInt(10) >= 7) {
      if (armour < 3) armour++;
      hasItem = true;
    }
    
    _keepMoveTime = _random.nextInt(300) + 80;
    direction = Direction.down;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    await _loadSprites();
    await _loadSpawnAnimation();
    
    state = TankState.idle;
    animation = spawnAnimation;
  }

  Future<void> _loadSpawnAnimation() async {
    try {
      final sprites = <Sprite>[];
      for (int i = 1; i <= 4; i++) {
        sprites.add(await gameRef.loadSprite('sprites/appear_$i.png'));
      }
      spawnAnimation = SpriteAnimation.spriteList(sprites, stepTime: 0.1);
    } catch (e) {
      print('Failed to load spawn animation: $e');
    }
  }

  Future<void> _loadSprites() async {
    String spriteName = _getSpriteName();
    
    try {
      final sprite1 = await gameRef.loadSprite('sprites/$spriteName.png');
      
      upAnimation = SpriteAnimation.spriteList([sprite1], stepTime: 0.1);
      downAnimation = SpriteAnimation.spriteList([sprite1], stepTime: 0.1);
      leftAnimation = SpriteAnimation.spriteList([sprite1], stepTime: 0.1);
      rightAnimation = SpriteAnimation.spriteList([sprite1], stepTime: 0.1);
    } catch (e) {
      print('Failed to load enemy sprites: $e');
    }
  }

  String _getSpriteName() {
    // Выбираем спрайт в зависимости от типа и брони
    if (hasItem) {
      // Красный мигающий враг с бонусом
      return 'enemy_a'; // Будет мигать красным
    }
    
    switch (type) {
      case EnemyType.typeA:
        return 'tank_silver${_random.nextInt(8) + 1}';
      case EnemyType.typeB:
        return 'tank_aqua${_random.nextInt(8) + 1}';
      case EnemyType.typeC:
        return 'tank_green${_random.nextInt(8) + 1}';
      case EnemyType.typeD:
        return 'tank_main${_random.nextInt(8) + 1}';
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isInitializing) {
      _initTimer -= dt;
      
      if (_initTimer <= 0) {
        _isInitializing = false;
        state = TankState.start;
        updateAnimation();
      }
      return;
    }
    
    if (isFreeze || state != TankState.start) return;
    
    _updateAI(dt);
    
    if (!_willCollide(dt)) {
      move(dt);
    } else {
      _keepMoveTime -= 25;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_isInitializing && spawnAnimation != null) {
      spawnAnimation!.getSprite().render(canvas, size: size);
      return;
    }
    
    // Мигание красным для врага с бонусом
    if (hasItem) {
      final time = DateTime.now().millisecondsSinceEpoch / 200;
      if (time.toInt() % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.x, size.y),
          Paint()..color = Colors.red.withOpacity(0.3),
        );
      }
    }
    
    // Поворачиваем спрайт
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    
    double rotationAngle = 0;
    switch (direction) {
      case Direction.up:
        rotationAngle = 0;
        break;
      case Direction.down:
        rotationAngle = 3.14159;
        break;
      case Direction.left:
        rotationAngle = -1.5708;
        break;
      case Direction.right:
        rotationAngle = 1.5708;
        break;
    }
    canvas.rotate(rotationAngle);
    canvas.translate(-size.x / 2, -size.y / 2);
    
    super.render(canvas);
    
    canvas.restore();
  }

  void _updateAI(double dt) {
    _moveTimer += dt * 60;
    _fireTimer += dt * 60;
    
    if (_moveTimer > _keepMoveTime) {
      _moveTimer = 0;
      _keepMoveTime = _random.nextInt(300) + 60;
      
      final p = _random.nextDouble();
      
      double targetChance;
      switch (type) {
        case EnemyType.typeA:
          targetChance = 0.3;
          break;
        case EnemyType.typeB:
        case EnemyType.typeC:
          targetChance = 0.5;
          break;
        case EnemyType.typeD:
          targetChance = 0.1;
          break;
      }
      
      if (p > targetChance) {
        _targetBase(p);
      } else {
        _randomDirection();
      }
    }
    
    if (_fireTimer > _fireDelay * 60) {
      _fireTimer = 0;
      _fireDelay = _random.nextInt(100) / 60 + 0.67;
      fire();
    }
  }

  void _targetBase(double p) {
    final targetX = GameConstants.baseX * GameConstants.cellSize + GameConstants.cellSize;
    final targetY = GameConstants.baseY * GameConstants.cellSize + GameConstants.cellSize;
    
    final dx = position.x - targetX;
    final dy = position.y - targetY;
    
    if (dx.abs() > dy.abs()) {
      direction = dx < 0 ? Direction.right : Direction.left;
    } else {
      direction = dy < 0 ? Direction.down : Direction.up;
    }
    
    if (p > 0.8) {
      _randomDirection();
    }
    
    turnDirection();
  }

  void _randomDirection() {
    final directions = [Direction.up, Direction.down, Direction.left, Direction.right];
    directions.remove(direction);
    direction = directions[_random.nextInt(directions.length)];
    turnDirection();
  }

  bool _willCollide(double dt) {
    Vector2 nextPos = position.clone();
    
    switch (direction) {
      case Direction.up:
        nextPos.y -= speed * dt;
        break;
      case Direction.down:
        nextPos.y += speed * dt;
        break;
      case Direction.left:
        nextPos.x -= speed * dt;
        break;
      case Direction.right:
        nextPos.x += speed * dt;
        break;
    }
    
    final halfSize = GameConstants.tankSize / 2;
    if (nextPos.x < halfSize || nextPos.x > GameConstants.mapPixelWidth - halfSize ||
        nextPos.y < halfSize || nextPos.y > GameConstants.mapPixelHeight - halfSize) {
      return true;
    }
    
    for (final brick in game.bricks) {
      if (brick.type == BrickType.bush || brick.type == BrickType.ice) {
        continue;
      }
      
      if (_checkCollisionWithBrick(nextPos, brick)) {
        return true;
      }
    }
    
    if (game.player1 != null && _checkCollisionWithTank(nextPos, game.player1!.position)) {
      return true;
    }
    if (game.player2 != null && _checkCollisionWithTank(nextPos, game.player2!.position)) {
      return true;
    }
    
    for (final enemy in game.enemies) {
      if (enemy == this) continue;
      if (_checkCollisionWithTank(nextPos, enemy.position)) {
        return true;
      }
    }
    
    if (game.baseEagle != null) {
      if (_checkCollisionWithBase(nextPos)) {
        return true;
      }
    }
    
    return false;
  }

  bool _checkCollisionWithBrick(Vector2 nextPos, Brick brick) {
    final tankRect = Rect.fromCenter(
      center: Offset(nextPos.x, nextPos.y),
      width: GameConstants.tankSize - 4,
      height: GameConstants.tankSize - 4,
    );
    
    final brickRect = Rect.fromLTWH(
      brick.position.x,
      brick.position.y,
      GameConstants.cellSize.toDouble(),
      GameConstants.cellSize.toDouble(),
    );
    
    return tankRect.overlaps(brickRect);
  }

  bool _checkCollisionWithTank(Vector2 nextPos, Vector2 otherPos) {
    final distance = nextPos.distanceTo(otherPos);
    return distance < GameConstants.tankSize - 4;
  }

  bool _checkCollisionWithBase(Vector2 nextPos) {
    final basePos = game.baseEagle!.position;
    final tankRect = Rect.fromCenter(
      center: Offset(nextPos.x, nextPos.y),
      width: GameConstants.tankSize - 4,
      height: GameConstants.tankSize - 4,
    );
    
    final baseRect = Rect.fromCenter(
      center: Offset(basePos.x, basePos.y),
      width: 32,
      height: 32,
    );
    
    return tankRect.overlaps(baseRect);
  }

  @override
  void takeDamage(Bullet bullet) {
    if (_isInitializing) return;
    
    if (armour > 0) {
      armour--;
      if (hasItem) {
        game._spawnBonus();
        hasItem = false;
      }
      return;
    }
    
    isDestroyed = true;
    state = TankState.dead;
    
    PlayerId? killedBy;
    if (bullet.owner is PlayerTank) {
      killedBy = (bullet.owner as PlayerTank).playerId;
    }
    
    game.destroyEnemy(this, killedBy);
  }
}
