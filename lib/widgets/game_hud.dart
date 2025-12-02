import 'package:flutter/material.dart';
import '../game/game_state.dart';

/// HUD (Head-Up Display) - отображение информации во время игры
class GameHud extends StatelessWidget {
  final GlobalGameState gameState;
  final int remainingEnemies;
  final int currentLevel;

  const GameHud({
    super.key,
    required this.gameState,
    required this.remainingEnemies,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 60,
        color: Colors.grey.shade800,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Счётчик врагов
            _buildEnemyCounter(),
            
            const Spacer(),
            
            // Информация об игроках
            _buildPlayerInfo(PlayerId.p1, gameState.p1Data),
            
            if (gameState.mode == GameMode.double_) ...[
              const SizedBox(height: 16),
              _buildPlayerInfo(PlayerId.p2, gameState.p2Data),
            ],
            
            const Spacer(),
            
            // Номер уровня
            _buildLevelIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnemyCounter() {
    return Column(
      children: [
        // Иконки врагов (как в оригинале - 2 столбца)
        Wrap(
          spacing: 2,
          runSpacing: 2,
          children: List.generate(
            remainingEnemies.clamp(0, 20),
            (index) => Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerInfo(PlayerId playerId, PlayerData data) {
    final label = playerId == PlayerId.p1 ? '1P' : '2P';
    final color = playerId == PlayerId.p1 ? Colors.green : Colors.amber;
    
    return Column(
      children: [
        // Метка игрока
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        
        // Иконка танка и количество жизней
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${data.lives}',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        // Очки
        Text(
          '${data.score}',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelIndicator() {
    return Column(
      children: [
        // Иконка флага
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Icon(
            Icons.flag,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        
        // Номер уровня
        Text(
          '$currentLevel',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Экран Game Over
class GameOverScreen extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const GameOverScreen({
    super.key,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Over текст
            const Text(
              'GAME',
              style: TextStyle(
                color: Colors.red,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            const Text(
              'OVER',
              style: TextStyle(
                color: Colors.red,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Кнопки
            _buildButton('RESTART', onRestart),
            const SizedBox(height: 16),
            _buildButton('MAIN MENU', onMainMenu),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

/// Экран перехода между уровнями
class StageScreen extends StatelessWidget {
  final int level;

  const StageScreen({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'STAGE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$level',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

