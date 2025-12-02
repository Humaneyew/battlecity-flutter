import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../game_state.dart';
import '../battle_city_game.dart';
import 'tank_base.dart';
import 'bullet.dart';
import 'brick.dart';
import 'bonus.dart';

/// Танк игрока с оригинальными спрайтами
class PlayerTank extends TankBase {
  final PlayerId playerId;
  final BattleCityGame game;
  
  TankLevel level = TankLevel.min;
  bool _isInitializing = true;
  double _initTimer = 1.5;
  
  // Анимация появления
  SpriteAnimation? spawnAnimation;
  SpriteAnimationTicker? spawnAnimationTicker;
  bool _showSpawnEffect = true;

  PlayerTank({
    required this.playerId,
    required Vector2 position,
    required this.game,
  }) : super(position: position) {
    speed = GameConstants.playerSpeed;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Загружаем спрайты в зависимости от уровня танка
    await _loadSprites();

    // Загружаем анимацию появления
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
      spawnAnimationTicker = spawnAnimation?.createTicker();
    } catch (e) {
      print('Failed to load spawn animation: $e');
    }
  }

  Future<void> _loadSprites() async {
    // Выбираем спрайты в зависимости от игрока и уровня
    String prefix = playerId == PlayerId.p1 ? 'tank' : 'player2';
    int spriteLevel = _getSpriteLevel();
    
    try {
      if (playerId == PlayerId.p1) {
        // Игрок 1 - зелёный танк
        final sprite1 = await gameRef.loadSprite('sprites/${prefix}${spriteLevel}.png');
        final sprite2 = await gameRef.loadSprite('sprites/${prefix}${spriteLevel}-1.png');
        
        // Создаём анимации для всех направлений
        upAnimation = SpriteAnimation.spriteList([sprite1, sprite2], stepTime: 0.1);
        downAnimation = SpriteAnimation.spriteList([sprite1, sprite2], stepTime: 0.1);
        leftAnimation = SpriteAnimation.spriteList([sprite1, sprite2], stepTime: 0.1);
        rightAnimation = SpriteAnimation.spriteList([sprite1, sprite2], stepTime: 0.1);
      } else {
        // Игрок 2 - жёлтый танк
        final sprite1 = await gameRef.loadSprite('sprites/${prefix}${spriteLevel}.png');
        final sprite2 = await gameRef.loadSprite('sprites/${prefix}${spriteLevel + 1}.png');
        
        upAnimation = SpriteAnimation.spriteList([sprite1, sprite2], stepTime: 0.1);
        downAnimation = SpriteAnimation.spriteList([sprite1, sprite2], stepTime: 0.1);
        leftAnimation = SpriteAnimation.spriteList([sprite1, sprite2], stepTime: 0.1);
        rightAnimation = SpriteAnimation.spriteList([sprite1, sprite2], stepTime: 0.1);
      }
    } catch (e) {
      print('Failed to load player sprites: $e');
      // Fallback - создаём пустую анимацию
      _createFallbackAnimation();
    }
  }

  void _createFallbackAnimation() {
    // Создаём простой спрайт если оригинальные не загрузились
    final paint = Paint()..color = playerId == PlayerId.p1 ? Colors.green : Colors.yellow;
    // Используем пустую анимацию как fallback
  }

  int _getSpriteLevel() {
    switch (level) {
      case TankLevel.min:
        return 1;
      case TankLevel.medium:
        return 2;
      case TankLevel.large:
        return 3;
      case TankLevel.super_:
        return 4;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Инициализация (анимация появления)
    if (_isInitializing) {
      spawnAnimationTicker?.update(dt);
      _initTimer -= dt;
      
      if (_initTimer <= 0) {
        _isInitializing = false;
        _showSpawnEffect = false;
        state = TankState.start;
        updateAnimation();
        startInvincibility(3.0);
      }
      return;
    }
    
    // Движение
    if (isMoving && state == TankState.start) {
      if (!_willCollide(dt)) {
        move(dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_isInitializing && spawnAnimation != null) {
      // Рендерим анимацию появления
      spawnAnimationTicker?.getSprite().render(canvas, size: size);
      return;
    }
    
    // Поворачиваем спрайт в зависимости от направления
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
    
    // Рисуем корабль если есть
    if (hasShip) {
      _renderShip(canvas);
    }
  }

  void _renderShip(Canvas canvas) {
    // TODO: загрузить спрайт корабля ship1.png / ship2.png
    final shipPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-2, -2, size.x + 4, size.y + 4),
        const Radius.circular(4),
      ),
      shipPaint,
    );
  }

  /// Проверка столкновений перед движением
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
        if (brick.type == BrickType.ice) {
          isOnIce = true;
        }
        continue;
      }
      if (brick.type == BrickType.water && hasShip) {
        continue;
      }
      
      if (_checkCollisionWithBrick(nextPos, brick)) {
        return true;
      }
    }
    
    for (final enemy in game.enemies) {
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

  void setDirection(Direction newDirection) {
    if (_isInitializing || isFreeze) return;
    
    if (direction != newDirection) {
      lastDirection = direction;
      direction = newDirection;
      turnDirection();
    }
    isMoving = true;
  }

  void stop() {
    isMoving = false;
  }

  void upgrade() {
    switch (level) {
      case TankLevel.min:
        level = TankLevel.medium;
        bulletPower = BulletPower.fast;
        break;
      case TankLevel.medium:
        level = TankLevel.large;
        bulletPower = BulletPower.fast;
        bulletMax = 2;
        break;
      case TankLevel.large:
        level = TankLevel.super_;
        bulletPower = BulletPower.super_;
        bulletMax = 2;
        break;
      case TankLevel.super_:
        break;
    }
    _loadSprites(); // Перезагружаем спрайты
  }

  void upgradeToMax() {
    level = TankLevel.super_;
    bulletPower = BulletPower.super_;
    bulletMax = 2;
    armour = 1;
    _loadSprites();
  }

  @override
  void takeDamage(Bullet bullet) {
    if (isInvincible || _isInitializing) return;
    
    if (hasShip) {
      setShip(false);
      return;
    }
    
    if (armour > 0) {
      armour--;
      if (level == TankLevel.super_) {
        level = TankLevel.large;
        bulletPower = BulletPower.fast;
      }
      _loadSprites();
      return;
    }
    
    isDestroyed = true;
    state = TankState.dead;
    game.destroyPlayer(this);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    if (other is BonusItem) {
      game.applyBonus(other.type, playerId);
      game.removeBonus(other);
    }
  }
}
