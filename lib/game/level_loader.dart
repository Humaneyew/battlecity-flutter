import 'dart:convert';
import 'package:flutter/services.dart';

/// Загрузчик уровней из JSON файлов
class LevelLoader {
  final Map<int, List<Map<String, dynamic>>> _cache = {};
  
  /// Список доступных уровней
  final List<int> availableLevels = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43
  ];

  /// Загрузить уровень
  Future<List<Map<String, dynamic>>> loadLevel(int levelNum) async {
    // Проверяем кэш
    if (_cache.containsKey(levelNum)) {
      return _cache[levelNum]!;
    }
    
    try {
      // Загружаем из assets
      final jsonString = await rootBundle.loadString('assets/levels/$levelNum.json');
      final jsonData = json.decode(jsonString);
      
      final List<Map<String, dynamic>> blocks = [];
      
      for (final item in jsonData['data']) {
        blocks.add({
          'x': item['x'],
          'y': item['y'],
          'type': item['type'],
        });
      }
      
      _cache[levelNum] = blocks;
      return blocks;
    } catch (e) {
      // Если не удалось загрузить, возвращаем дефолтный уровень
      print('Failed to load level $levelNum: $e');
      return _getDefaultLevel();
    }
  }

  /// Дефолтный уровень если не удалось загрузить
  List<Map<String, dynamic>> _getDefaultLevel() {
    final List<Map<String, dynamic>> blocks = [];
    
    // Создаём простой уровень с блоками
    // Верхняя стена
    for (int x = 0; x < 26; x += 2) {
      blocks.add({'x': x, 'y': 2, 'type': 0});
      blocks.add({'x': x + 1, 'y': 2, 'type': 0});
    }
    
    // Боковые стены
    for (int y = 4; y < 20; y += 2) {
      blocks.add({'x': 2, 'y': y, 'type': 0});
      blocks.add({'x': 3, 'y': y, 'type': 0});
      blocks.add({'x': 22, 'y': y, 'type': 0});
      blocks.add({'x': 23, 'y': y, 'type': 0});
    }
    
    // Центральные блоки
    for (int x = 10; x < 16; x += 2) {
      for (int y = 8; y < 14; y += 2) {
        blocks.add({'x': x, 'y': y, 'type': 0});
        blocks.add({'x': x + 1, 'y': y, 'type': 0});
      }
    }
    
    // Камни
    blocks.add({'x': 6, 'y': 10, 'type': 1});
    blocks.add({'x': 7, 'y': 10, 'type': 1});
    blocks.add({'x': 18, 'y': 10, 'type': 1});
    blocks.add({'x': 19, 'y': 10, 'type': 1});
    
    // Вода
    blocks.add({'x': 12, 'y': 16, 'type': 2});
    blocks.add({'x': 13, 'y': 16, 'type': 2});
    
    // Кусты
    blocks.add({'x': 6, 'y': 18, 'type': 3});
    blocks.add({'x': 7, 'y': 18, 'type': 3});
    blocks.add({'x': 18, 'y': 18, 'type': 3});
    blocks.add({'x': 19, 'y': 18, 'type': 3});
    
    // Лёд
    blocks.add({'x': 10, 'y': 20, 'type': 4});
    blocks.add({'x': 11, 'y': 20, 'type': 4});
    blocks.add({'x': 14, 'y': 20, 'type': 4});
    blocks.add({'x': 15, 'y': 20, 'type': 4});
    
    // Защита базы
    blocks.add({'x': 11, 'y': 23, 'type': 0});
    blocks.add({'x': 12, 'y': 23, 'type': 0});
    blocks.add({'x': 13, 'y': 23, 'type': 0});
    blocks.add({'x': 14, 'y': 23, 'type': 0});
    blocks.add({'x': 11, 'y': 24, 'type': 0});
    blocks.add({'x': 11, 'y': 25, 'type': 0});
    blocks.add({'x': 14, 'y': 24, 'type': 0});
    blocks.add({'x': 14, 'y': 25, 'type': 0});
    
    return blocks;
  }

  /// Получить следующий уровень
  int getNextLevel(int currentLevel) {
    final index = availableLevels.indexOf(currentLevel);
    if (index >= 0 && index < availableLevels.length - 1) {
      return availableLevels[index + 1];
    }
    return availableLevels[0]; // Возвращаемся к первому уровню
  }

  /// Очистить кэш
  void clearCache() {
    _cache.clear();
  }
}

