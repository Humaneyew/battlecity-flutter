import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/battle_city_game.dart';
import 'widgets/game_controls.dart';
import 'widgets/main_menu.dart';
import 'game/game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Блокируем только горизонтальную ориентацию
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Полноэкранный режим
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const BattleCityApp());
}

class BattleCityApp extends StatelessWidget {
  const BattleCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battle City',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        fontFamily: 'PressStart2P',
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BattleCityGame game;
  bool showMenu = true;
  GameMode gameMode = GameMode.single;

  @override
  void initState() {
    super.initState();
    game = BattleCityGame(
      onGameOver: _onGameOver,
      onLevelComplete: _onLevelComplete,
    );
  }

  void _startGame(GameMode mode) {
    setState(() {
      gameMode = mode;
      showMenu = false;
    });
    game.startGame(mode);
  }

  void _onGameOver() {
    setState(() {
      showMenu = true;
    });
  }

  void _onLevelComplete() {
    game.nextLevel();
  }

  void _pauseGame() {
    game.togglePause();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Игровое поле
          GameWidget(game: game),
          
          // Главное меню
          if (showMenu)
            MainMenu(
              onStartSingle: () => _startGame(GameMode.single),
              onStartDouble: () => _startGame(GameMode.double_),
            ),
          
          // Виртуальные кнопки управления (только во время игры)
          if (!showMenu)
            GameControls(
              onDirectionChanged: (direction) {
                game.setPlayerDirection(direction);
              },
              onDirectionReleased: () {
                game.stopPlayer();
              },
              onFire: () {
                game.playerFire();
              },
              onPause: _pauseGame,
            ),
          
          // Индикатор паузы
          if (!showMenu && game.isPaused)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: const Text(
                  'PAUSE',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

