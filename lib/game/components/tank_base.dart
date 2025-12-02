import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../game_state.dart';
import '../battle_city_game.dart';
import 'bullet.dart';

/// Базовый класс танка с поддержкой спрайтов
abstract class TankBase extends SpriteAnimationComponent with HasGameRef<BattleCityGame>, CollisionCallbacks {
  Direction direction = Direction.up;
  Direction lastDirection = Direction.up;
  
  double speed = GameConstants.playerSpeed;
  bool isInvincible = false;
  bool isFreeze = false;
  bool hasShip = false;
  bool isOnIce = false;
  bool isDestroyed = false;
  bool isMoving = false;
  
  int life = 1;
  int armour = 0;
  int bulletMax = 1;
  BulletPower bulletPower = BulletPower.normal;
  TankState state = TankState.idle;
  
  final List<Bullet> activeBullets = [];
  
  double shootCooldown = 0;
  double invincibleTimer = 0;
  double slideTime = 0;
  
  // Спрайты для разных направлений
  late SpriteAnimation upAnimation;
  late SpriteAnimation downAnimation;
  late SpriteAnimation leftAnimation;
  late SpriteAnimation rightAnimation;
  
  // Эффект неуязвимости
  SpriteAnimation? invincibleAnimation;
  SpriteAnimationTicker? invincibleTicker;
  
  late RectangleHitbox hitbox;

  TankBase({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(GameConstants.tankSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    hitbox = RectangleHitbox(
      size: Vector2.all(GameConstants.tankSize - 4),
      position: Vector2.all(2),
    );
    add(hitbox);
    
    // Загружаем анимацию неуязвимости
    await _loadInvincibleAnimation();
  }

  Future<void> _loadInvincibleAnimation() async {
    try {
      final sprite1 = await gameRef.loadSprite('sprites/invincible1.png');
      final sprite2 = await gameRef.loadSprite('sprites/invincible2.png');
      invincibleAnimation = SpriteAnimation.spriteList(
        [sprite1, sprite2],
        stepTime: 0.1,
      );
      invincibleTicker = invincibleAnimation?.createTicker();
    } catch (e) {
      // Игнорируем если спрайты не найдены
    }
  }

  /// Обновление анимации в зависимости от направления
  void updateAnimation() {
    switch (direction) {
      case Direction.up:
        animation = upAnimation;
        angle = 0;
        break;
      case Direction.down:
        animation = downAnimation;
        angle = 0;
        break;
      case Direction.left:
        animation = leftAnimation;
        angle = 0;
        break;
      case Direction.right:
        animation = rightAnimation;
        angle = 0;
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Эффект неуязвимости
    if (isInvincible && invincibleAnimation != null) {
      final sprite = invincibleTicker?.getSprite();
      sprite?.render(canvas, size: size);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isDestroyed || state == TankState.dead) return;
    
    // Обновляем кулдаун стрельбы
    if (shootCooldown > 0) {
      shootCooldown -= dt;
    }
    
    // Обновляем таймер неуязвимости
    if (invincibleTimer > 0) {
      invincibleTimer -= dt;
      if (invincibleTimer <= 0) {
        isInvincible = false;
      }
    }
    
    // Очищаем уничтоженные пули из списка
    activeBullets.removeWhere((b) => b.isDestroyed);

    // Обновляем анимацию неуязвимости
    if (isInvincible && invincibleAnimation != null) {
      invincibleTicker?.update(dt);
    }
  }

  /// Движение танка
  void move(double dt) {
    if (isFreeze || state != TankState.start) return;
    
    Vector2 velocity = Vector2.zero();
    
    switch (direction) {
      case Direction.up:
        velocity = Vector2(0, -speed);
        break;
      case Direction.down:
        velocity = Vector2(0, speed);
        break;
      case Direction.left:
        velocity = Vector2(-speed, 0);
        break;
      case Direction.right:
        velocity = Vector2(speed, 0);
        break;
    }
    
    // Проверка границ карты
    final newX = position.x + velocity.x * dt;
    final newY = position.y + velocity.y * dt;
    
    final halfSize = GameConstants.tankSize / 2;
    
    if (newX >= halfSize && newX <= GameConstants.mapPixelWidth - halfSize) {
      position.x = newX;
    }
    if (newY >= halfSize && newY <= GameConstants.mapPixelHeight - halfSize) {
      position.y = newY;
    }
  }

  /// Смена направления - выравнивание по сетке
  void turnDirection() {
    if (direction == Direction.left || direction == Direction.right) {
      position.y = (position.y / GameConstants.cellSize).round() * GameConstants.cellSize.toDouble();
    } else {
      position.x = (position.x / GameConstants.cellSize).round() * GameConstants.cellSize.toDouble();
    }
    updateAnimation();
  }

  /// Выстрел
  bool fire() {
    if (shootCooldown > 0) return false;
    if (activeBullets.length >= bulletMax) return false;
    
    // Создаём пулю
    final bullet = Bullet(
      position: position.clone(),
      direction: direction,
      power: bulletPower,
      owner: this,
      game: gameRef,
    );
    
    activeBullets.add(bullet);
    gameRef.addBullet(bullet);
    
    // Устанавливаем кулдаун
    shootCooldown = 0.3;
    
    return true;
  }

  /// Неуязвимость
  void startInvincibility(double duration) {
    isInvincible = true;
    invincibleTimer = duration;
    invincibleTicker?.reset();
  }

  /// Заморозка
  void setFreeze(bool freeze) {
    isFreeze = freeze;
    if (freeze) {
      state = TankState.freeze;
    } else {
      state = TankState.start;
    }
  }

  /// Установка корабля (возможность ездить по воде)
  void setShip(bool value) {
    hasShip = value;
  }

  /// Получение урона
  void takeDamage(Bullet bullet);
}
