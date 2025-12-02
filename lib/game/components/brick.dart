import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../game_state.dart';
import '../battle_city_game.dart';

/// Блок карты с оригинальными спрайтами
class Brick extends SpriteComponent with HasGameRef<BattleCityGame> {
  BrickType type;
  
  int gridX;
  int gridY;
  
  // Маска разрушения для кирпичной стены
  List<bool> blockMask = [true, true, true, true];
  
  // Спрайты для разных типов
  Sprite? wallSprite;
  Sprite? stoneSprite;
  Sprite? waterSprite1;
  Sprite? waterSprite2;
  Sprite? bushSprite;
  Sprite? iceSprite;
  
  double _waterAnimTimer = 0;
  bool _waterFrame = false;

  Brick({
    required Vector2 gridPosition,
    required this.type,
  }) : gridX = gridPosition.x.toInt(),
       gridY = gridPosition.y.toInt(),
       super(
         position: Vector2(
           gridPosition.x * GameConstants.cellSize,
           gridPosition.y * GameConstants.cellSize,
         ),
         size: Vector2.all(GameConstants.cellSize.toDouble()),
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Загружаем спрайты
    await _loadSprites();
    
    // Устанавливаем текущий спрайт
    _updateSprite();
    
    // Хитбокс только для твёрдых блоков
    if (type != BrickType.bush && type != BrickType.ice) {
      add(RectangleHitbox(size: size));
    }
    
    // Кусты рендерятся поверх танков
    if (type == BrickType.bush) {
      priority = 10;
    }
  }

  Future<void> _loadSprites() async {
    try {
      wallSprite = await gameRef.loadSprite('sprites/brick.png');
      stoneSprite = await gameRef.loadSprite('sprites/stone.png');
      waterSprite1 = await gameRef.loadSprite('sprites/water1.png');
      waterSprite2 = await gameRef.loadSprite('sprites/water2.png');
      bushSprite = await gameRef.loadSprite('sprites/bush.png');
      iceSprite = await gameRef.loadSprite('sprites/ice.png');
    } catch (e) {
      print('Failed to load brick sprites: $e');
    }
  }

  void _updateSprite() {
    switch (type) {
      case BrickType.wall:
        sprite = wallSprite;
        break;
      case BrickType.stone:
        sprite = stoneSprite;
        break;
      case BrickType.water:
        sprite = _waterFrame ? waterSprite2 : waterSprite1;
        break;
      case BrickType.bush:
        sprite = bushSprite;
        break;
      case BrickType.ice:
        sprite = iceSprite;
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Анимация воды
    if (type == BrickType.water) {
      _waterAnimTimer += dt;
      if (_waterAnimTimer >= 0.5) {
        _waterAnimTimer = 0;
        _waterFrame = !_waterFrame;
        _updateSprite();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (type == BrickType.wall && !blockMask.every((b) => b)) {
      // Рисуем частично разрушенную стену
      _renderPartialWall(canvas);
    } else {
      super.render(canvas);
    }
  }

  void _renderPartialWall(Canvas canvas) {
    if (wallSprite == null) return;
    
    final halfSize = size.x / 2;
    
    for (int i = 0; i < 4; i++) {
      if (!blockMask[i]) continue;
      
      final x = (i % 2) * halfSize;
      final y = (i ~/ 2) * halfSize;
      
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(x, y, halfSize, halfSize));
      wallSprite!.render(canvas, size: size);
      canvas.restore();
    }
  }

  /// Повреждение блока пулей
  void damage(Direction bulletDirection) {
    if (type != BrickType.wall) return;
    
    switch (bulletDirection) {
      case Direction.down:
        if (!blockMask[0] && !blockMask[1]) {
          blockMask[2] = false;
          blockMask[3] = false;
        } else {
          blockMask[0] = false;
          blockMask[1] = false;
        }
        break;
        
      case Direction.up:
        if (!blockMask[2] && !blockMask[3]) {
          blockMask[0] = false;
          blockMask[1] = false;
        } else {
          blockMask[2] = false;
          blockMask[3] = false;
        }
        break;
        
      case Direction.right:
        if (!blockMask[0] && !blockMask[2]) {
          blockMask[1] = false;
          blockMask[3] = false;
        } else {
          blockMask[0] = false;
          blockMask[2] = false;
        }
        break;
        
      case Direction.left:
        if (!blockMask[1] && !blockMask[3]) {
          blockMask[0] = false;
          blockMask[2] = false;
        } else {
          blockMask[1] = false;
          blockMask[3] = false;
        }
        break;
    }
    
    if (!blockMask.any((b) => b)) {
      gameRef.removeBrick(this);
    }
  }

  void changeType(BrickType newType) {
    type = newType;
    blockMask = [true, true, true, true];
    _updateSprite();
  }
}
