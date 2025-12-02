// Игровые константы и перечисления - аналог game.gd

/// Направление движения
enum Direction { up, down, left, right }

/// Уровень танка игрока
enum TankLevel { min, medium, large, super_ }

/// ID игрока
enum PlayerId { p1, p2 }

/// Тип блока карты
enum BrickType {
  wall,   // 0 - кирпичная стена (разрушаемая)
  stone,  // 1 - каменная стена
  water,  // 2 - вода
  bush,   // 3 - кусты
  ice,    // 4 - лёд
}

/// Тип игрового объекта
enum ObjType { player, enemy, brick, base, bullet, bonus }

/// Тип бонуса
enum BonusType {
  grenade,  // Граната - уничтожает всех врагов
  helmet,   // Шлем - неуязвимость
  clock,    // Часы - замораживает врагов
  shovel,   // Лопата - укрепляет базу
  tank,     // Танк - дополнительная жизнь
  star,     // Звезда - улучшение танка
  gun,      // Пушка - максимальное улучшение
  boat,     // Лодка - можно ездить по воде
}

/// Сила пули
enum BulletPower { normal, fast, super_ }

/// Состояние танка
enum TankState { idle, start, dead, freeze }

/// Тип вражеского танка
enum EnemyType { typeA, typeB, typeC, typeD }

/// Состояние игры
enum GameState { idle, playing, paused, gameOver, levelComplete }

/// Режим игры
enum GameMode { single, double_ }

/// Игровые константы
class GameConstants {
  static const int cellSize = 16;
  static const int mapWidth = 26;
  static const int mapHeight = 26;
  static const double mapPixelWidth = cellSize * mapWidth * 1.0;
  static const double mapPixelHeight = cellSize * mapHeight * 1.0;
  
  // Скорости
  static const double playerSpeed = 80.0;
  static const double enemySpeedNormal = 70.0;
  static const double enemySpeedFast = 100.0;
  static const double bulletSpeedNormal = 180.0;
  static const double bulletSpeedFast = 380.0;
  
  // Размер танка
  static const double tankSize = 28.0;
  
  // Позиции спавна игроков
  static const List<int> player1SpawnX = [8, 9];
  static const List<int> player1SpawnY = [24, 25];
  static const List<int> player2SpawnX = [16, 17];
  static const List<int> player2SpawnY = [24, 25];
  
  // Позиции спавна врагов
  static const List<List<int>> enemySpawnPositions = [
    [0, 0],
    [12, 0],
    [24, 0],
  ];
  
  // Позиция базы
  static const int baseX = 12;
  static const int baseY = 24;
  
  // Позиции блоков вокруг базы
  static const List<List<int>> baseBrickPositions = [
    [11, 25], [11, 24], [11, 23],
    [12, 23], [13, 23],
    [14, 23], [14, 24], [14, 25],
  ];
  
  // Начальное количество врагов
  static const int initialEnemyCount = 20;
  
  // Начальные жизни
  static const int initialLives = 3;
}

/// Данные игрока
class PlayerData {
  int score = 0;
  int lives = GameConstants.initialLives;
  TankLevel level = TankLevel.min;
  int armour = 0;
  bool hasShip = false;
  
  Map<EnemyType, int> killCount = {
    EnemyType.typeA: 0,
    EnemyType.typeB: 0,
    EnemyType.typeC: 0,
    EnemyType.typeD: 0,
  };
  
  void reset() {
    score = 0;
    lives = GameConstants.initialLives;
    level = TankLevel.min;
    armour = 0;
    hasShip = false;
    killCount = {
      EnemyType.typeA: 0,
      EnemyType.typeB: 0,
      EnemyType.typeC: 0,
      EnemyType.typeD: 0,
    };
  }
  
  void resetKillCount() {
    killCount = {
      EnemyType.typeA: 0,
      EnemyType.typeB: 0,
      EnemyType.typeC: 0,
      EnemyType.typeD: 0,
    };
  }
}

/// Глобальное состояние игры
class GlobalGameState {
  PlayerData p1Data = PlayerData();
  PlayerData p2Data = PlayerData();
  int currentLevel = 1;
  GameMode mode = GameMode.single;
  GameState state = GameState.idle;
  
  void reset() {
    p1Data.reset();
    p2Data.reset();
    currentLevel = 1;
    state = GameState.idle;
  }
}

