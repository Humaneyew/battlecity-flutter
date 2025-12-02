import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game_state.dart';
import 'components/player_tank.dart';
import 'components/enemy_tank.dart';
import 'components/bullet.dart';
import 'components/brick.dart';
import 'components/base_eagle.dart';
import 'components/bonus.dart';
import 'level_loader.dart';
import 'audio_manager.dart';

/// Основной класс игры Battle City
class BattleCityGame extends FlameGame with HasCollisionDetection {
  final VoidCallback onGameOver;
  final VoidCallback onLevelComplete;
  
  late GlobalGameState gameState;
  late LevelLoader levelLoader;
  late AudioManager audioManager;
  
  // Игровые компоненты
  PlayerTank? player1;
  PlayerTank? player2;
  BaseEagle? baseEagle;
  
  // Списки объектов
  final List<EnemyTank> enemies = [];
  final List<Bullet> bullets = [];
  final List<Brick> bricks = [];
  final List<BonusItem> bonuses = [];
  
  // Счётчики
  int remainingEnemies = GameConstants.initialEnemyCount;
  int maxEnemiesOnScreen = 4;
  double enemySpawnTimer = 0;
  double enemySpawnDelay = 3.0;
  
  // Флаги состояния
  bool _isPaused = false;
  bool _isGameStarted = false;
  bool _baseDestroyed = false;
  
  // Таймер для бонусов
  double? freezeTimer;
  double? shovelTimer;

  BattleCityGame({
    required this.onGameOver,
    required this.onLevelComplete,
  });

  bool get isPaused => _isPaused;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    gameState = GlobalGameState();
    levelLoader = LevelLoader();
    audioManager = AudioManager();
    
    // Устанавливаем камеру
    camera.viewfinder.anchor = Anchor.topLeft;
    
    // Добавляем фон
    add(RectangleComponent(
      size: Vector2(GameConstants.mapPixelWidth, GameConstants.mapPixelHeight),
      paint: Paint()..color = Colors.black,
    ));
  }

  /// Запуск игры
  void startGame(GameMode mode) {
    gameState.mode = mode;
    gameState.reset();
    gameState.state = GameState.playing;
    _isGameStarted = true;
    _isPaused = false;
    _baseDestroyed = false;
    
    loadLevel(gameState.currentLevel);
  }

  /// Загрузка уровня
  Future<void> loadLevel(int levelNum) async {
    // Очищаем текущий уровень
    clearLevel();
    
    remainingEnemies = GameConstants.initialEnemyCount;
    enemySpawnTimer = 0;
    
    // Загружаем карту
    final levelData = await levelLoader.loadLevel(levelNum);
    
    // Создаём блоки карты
    for (final blockData in levelData) {
      final brick = Brick(
        gridPosition: Vector2(blockData['x'].toDouble(), blockData['y'].toDouble()),
        type: BrickType.values[blockData['type'] as int],
      );
      bricks.add(brick);
      add(brick);
    }
    
    // Создаём базу
    baseEagle = BaseEagle(
      position: Vector2(
        GameConstants.baseX * GameConstants.cellSize.toDouble() + GameConstants.cellSize,
        GameConstants.baseY * GameConstants.cellSize.toDouble() + GameConstants.cellSize,
      ),
    );
    add(baseEagle!);
    
    // Создаём защитные блоки вокруг базы
    _createBaseBricks();
    
    // Создаём игрока 1
    _spawnPlayer1();
    
    // Создаём игрока 2 (если режим на двоих)
    if (gameState.mode == GameMode.double_) {
      _spawnPlayer2();
    }
    
    // Запускаем спавн врагов
    _spawnEnemy();
  }

  void _createBaseBricks() {
    for (final pos in GameConstants.baseBrickPositions) {
      // Проверяем, нет ли уже блока на этой позиции
      final existingBrick = bricks.where((b) => 
        b.gridX == pos[0] && b.gridY == pos[1]
      ).firstOrNull;
      
      if (existingBrick == null) {
        final brick = Brick(
          gridPosition: Vector2(pos[0].toDouble(), pos[1].toDouble()),
          type: BrickType.wall,
        );
        bricks.add(brick);
        add(brick);
      }
    }
  }

  void _spawnPlayer1() {
    player1 = PlayerTank(
      playerId: PlayerId.p1,
      position: Vector2(
        9 * GameConstants.cellSize.toDouble(),
        25 * GameConstants.cellSize.toDouble(),
      ),
      game: this,
    );
    add(player1!);
  }

  void _spawnPlayer2() {
    player2 = PlayerTank(
      playerId: PlayerId.p2,
      position: Vector2(
        17 * GameConstants.cellSize.toDouble(),
        25 * GameConstants.cellSize.toDouble(),
      ),
      game: this,
    );
    add(player2!);
  }

  void _spawnEnemy() {
    if (remainingEnemies <= 0 || enemies.length >= maxEnemiesOnScreen) return;
    
    // Выбираем случайную позицию спавна
    final spawnIndex = DateTime.now().millisecondsSinceEpoch % 3;
    final spawnPos = GameConstants.enemySpawnPositions[spawnIndex];
    
    // Выбираем случайный тип врага
    final enemyTypes = EnemyType.values;
    final enemyType = enemyTypes[DateTime.now().millisecondsSinceEpoch % enemyTypes.length];
    
    final enemy = EnemyTank(
      position: Vector2(
        spawnPos[0] * GameConstants.cellSize.toDouble() + GameConstants.tankSize / 2,
        spawnPos[1] * GameConstants.cellSize.toDouble() + GameConstants.tankSize / 2,
      ),
      type: enemyType,
      game: this,
    );
    
    enemies.add(enemy);
    add(enemy);
    remainingEnemies--;
  }

  /// Очистка уровня
  void clearLevel() {
    // Удаляем всех врагов
    for (final enemy in enemies) {
      enemy.removeFromParent();
    }
    enemies.clear();
    
    // Удаляем все пули
    for (final bullet in bullets) {
      bullet.removeFromParent();
    }
    bullets.clear();
    
    // Удаляем все блоки
    for (final brick in bricks) {
      brick.removeFromParent();
    }
    bricks.clear();
    
    // Удаляем бонусы
    for (final bonus in bonuses) {
      bonus.removeFromParent();
    }
    bonuses.clear();
    
    // Удаляем базу
    baseEagle?.removeFromParent();
    baseEagle = null;
    
    // Удаляем игроков
    player1?.removeFromParent();
    player1 = null;
    player2?.removeFromParent();
    player2 = null;
  }

  @override
  void update(double dt) {
    if (!_isGameStarted || _isPaused) return;
    
    super.update(dt);
    
    // Спавн врагов
    enemySpawnTimer += dt;
    if (enemySpawnTimer >= enemySpawnDelay) {
      enemySpawnTimer = 0;
      _spawnEnemy();
    }
    
    // Таймер заморозки
    if (freezeTimer != null) {
      freezeTimer = freezeTimer! - dt;
      if (freezeTimer! <= 0) {
        freezeTimer = null;
        _unfreezeEnemies();
      }
    }
    
    // Таймер лопаты (укреплённая база)
    if (shovelTimer != null) {
      shovelTimer = shovelTimer! - dt;
      if (shovelTimer! <= 0) {
        shovelTimer = null;
        _resetBaseBricks();
      }
    }
    
    // Проверка победы
    if (remainingEnemies <= 0 && enemies.isEmpty) {
      _levelComplete();
    }
    
    // Проверка поражения
    if (_baseDestroyed || _allPlayersDestroyed()) {
      _gameOver();
    }
  }

  bool _allPlayersDestroyed() {
    if (gameState.mode == GameMode.single) {
      return gameState.p1Data.lives <= 0 && (player1 == null || player1!.isDestroyed);
    } else {
      return gameState.p1Data.lives <= 0 && gameState.p2Data.lives <= 0 &&
             (player1 == null || player1!.isDestroyed) &&
             (player2 == null || player2!.isDestroyed);
    }
  }

  void _levelComplete() {
    gameState.state = GameState.levelComplete;
    gameState.currentLevel++;
    onLevelComplete();
  }

  void _gameOver() {
    gameState.state = GameState.gameOver;
    _isGameStarted = false;
    onGameOver();
  }

  /// Следующий уровень
  void nextLevel() {
    loadLevel(gameState.currentLevel);
  }

  /// Пауза
  void togglePause() {
    _isPaused = !_isPaused;
    gameState.state = _isPaused ? GameState.paused : GameState.playing;
  }

  /// Управление игроком
  void setPlayerDirection(Direction direction) {
    player1?.setDirection(direction);
  }

  void stopPlayer() {
    player1?.stop();
  }

  void playerFire() {
    player1?.fire();
  }

  /// Добавление пули
  void addBullet(Bullet bullet) {
    bullets.add(bullet);
    add(bullet);
  }

  /// Удаление пули
  void removeBullet(Bullet bullet) {
    bullets.remove(bullet);
    bullet.removeFromParent();
  }

  /// Уничтожение врага
  void destroyEnemy(EnemyTank enemy, PlayerId? killedBy) {
    enemies.remove(enemy);
    enemy.removeFromParent();
    
    // Начисляем очки
    if (killedBy != null) {
      final playerData = killedBy == PlayerId.p1 ? gameState.p1Data : gameState.p2Data;
      playerData.killCount[enemy.type] = (playerData.killCount[enemy.type] ?? 0) + 1;
      
      // Очки за тип врага
      int points = 100;
      switch (enemy.type) {
        case EnemyType.typeA:
          points = 100;
          break;
        case EnemyType.typeB:
          points = 200;
          break;
        case EnemyType.typeC:
          points = 300;
          break;
        case EnemyType.typeD:
          points = 400;
          break;
      }
      playerData.score += points;
    }
    
    // Спавн бонуса если у врага был предмет
    if (enemy.hasItem) {
      _spawnBonus();
    }
  }

  /// Уничтожение игрока
  void destroyPlayer(PlayerTank player) {
    final playerData = player.playerId == PlayerId.p1 
        ? gameState.p1Data 
        : gameState.p2Data;
    
    playerData.lives--;
    
    if (playerData.lives > 0) {
      // Респавн игрока
      Future.delayed(const Duration(seconds: 2), () {
        if (player.playerId == PlayerId.p1) {
          _spawnPlayer1();
        } else {
          _spawnPlayer2();
        }
      });
    }
    
    player.removeFromParent();
    if (player.playerId == PlayerId.p1) {
      player1 = null;
    } else {
      player2 = null;
    }
  }

  /// Уничтожение базы
  void destroyBase() {
    _baseDestroyed = true;
    baseEagle?.destroy();
  }

  /// Удаление блока
  void removeBrick(Brick brick) {
    bricks.remove(brick);
    brick.removeFromParent();
  }

  /// Спавн бонуса
  void _spawnBonus() {
    // Выбираем случайную позицию (не на базе и не рядом с игроком)
    double x, y;
    do {
      x = (DateTime.now().millisecondsSinceEpoch % 24 + 1) * GameConstants.cellSize.toDouble();
      y = (DateTime.now().microsecondsSinceEpoch % 24 + 1) * GameConstants.cellSize.toDouble();
    } while (_isNearBase(x, y) || _isNearPlayer(x, y));
    
    // Случайный тип бонуса
    final bonusTypes = BonusType.values;
    final bonusType = bonusTypes[DateTime.now().millisecondsSinceEpoch % bonusTypes.length];
    
    final bonus = BonusItem(
      position: Vector2(x, y),
      type: bonusType,
      game: this,
    );
    
    bonuses.add(bonus);
    add(bonus);
  }

  bool _isNearBase(double x, double y) {
    final baseX = GameConstants.baseX * GameConstants.cellSize;
    final baseY = GameConstants.baseY * GameConstants.cellSize;
    return (x - baseX).abs() < 48 && (y - baseY).abs() < 48;
  }

  bool _isNearPlayer(double x, double y) {
    if (player1 != null) {
      if ((x - player1!.position.x).abs() < 32 && (y - player1!.position.y).abs() < 32) {
        return true;
      }
    }
    if (player2 != null) {
      if ((x - player2!.position.x).abs() < 32 && (y - player2!.position.y).abs() < 32) {
        return true;
      }
    }
    return false;
  }

  /// Применение бонуса
  void applyBonus(BonusType type, PlayerId playerId) {
    final player = playerId == PlayerId.p1 ? player1 : player2;
    final playerData = playerId == PlayerId.p1 ? gameState.p1Data : gameState.p2Data;
    
    switch (type) {
      case BonusType.grenade:
        // Уничтожить всех врагов на экране
        for (final enemy in List.from(enemies)) {
          destroyEnemy(enemy, playerId);
        }
        break;
        
      case BonusType.helmet:
        // Неуязвимость
        player?.startInvincibility(10.0);
        break;
        
      case BonusType.clock:
        // Заморозить врагов
        freezeTimer = 10.0;
        _freezeEnemies();
        break;
        
      case BonusType.shovel:
        // Укрепить базу
        shovelTimer = 15.0;
        _reinforceBaseBricks();
        break;
        
      case BonusType.tank:
        // Дополнительная жизнь
        playerData.lives++;
        break;
        
      case BonusType.star:
        // Улучшение танка
        player?.upgrade();
        break;
        
      case BonusType.gun:
        // Максимальное улучшение
        player?.upgradeToMax();
        break;
        
      case BonusType.boat:
        // Можно ездить по воде
        player?.setShip(true);
        break;
    }
  }

  void _freezeEnemies() {
    for (final enemy in enemies) {
      enemy.setFreeze(true);
    }
  }

  void _unfreezeEnemies() {
    for (final enemy in enemies) {
      enemy.setFreeze(false);
    }
  }

  void _reinforceBaseBricks() {
    for (final pos in GameConstants.baseBrickPositions) {
      final brick = bricks.where((b) => b.gridX == pos[0] && b.gridY == pos[1]).firstOrNull;
      if (brick != null) {
        brick.changeType(BrickType.stone);
      }
    }
  }

  void _resetBaseBricks() {
    for (final pos in GameConstants.baseBrickPositions) {
      final brick = bricks.where((b) => b.gridX == pos[0] && b.gridY == pos[1]).firstOrNull;
      if (brick != null) {
        brick.changeType(BrickType.wall);
      }
    }
  }

  /// Удаление бонуса
  void removeBonus(BonusItem bonus) {
    bonuses.remove(bonus);
    bonus.removeFromParent();
  }

  /// Получить блок по координатам сетки
  Brick? getBrickAt(int x, int y) {
    return bricks.where((b) => b.gridX == x && b.gridY == y).firstOrNull;
  }

  @override
  Color backgroundColor() => Colors.grey.shade900;
}

