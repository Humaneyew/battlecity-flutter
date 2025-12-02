import 'package:flutter/material.dart';
import '../game/game_state.dart';

/// Виртуальный геймпад с D-pad слева и кнопками справа
class GameControls extends StatelessWidget {
  final Function(Direction) onDirectionChanged;
  final VoidCallback onDirectionReleased;
  final VoidCallback onFire;
  final VoidCallback onPause;

  const GameControls({
    super.key,
    required this.onDirectionChanged,
    required this.onDirectionReleased,
    required this.onFire,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // D-Pad слева внизу
        Positioned(
          left: 20,
          bottom: 20,
          child: DPad(
            onDirectionChanged: onDirectionChanged,
            onDirectionReleased: onDirectionReleased,
          ),
        ),
        
        // Кнопки справа внизу
        Positioned(
          right: 20,
          bottom: 20,
          child: ActionButtons(
            onFire: onFire,
            onPause: onPause,
          ),
        ),
        
        // Кнопка паузы вверху справа
        Positioned(
          right: 20,
          top: 20,
          child: PauseButton(onPause: onPause),
        ),
      ],
    );
  }
}

/// D-Pad - крестовина управления
class DPad extends StatefulWidget {
  final Function(Direction) onDirectionChanged;
  final VoidCallback onDirectionReleased;

  const DPad({
    super.key,
    required this.onDirectionChanged,
    required this.onDirectionReleased,
  });

  @override
  State<DPad> createState() => _DPadState();
}

class _DPadState extends State<DPad> {
  Direction? _currentDirection;

  void _handleDirection(Direction direction) {
    if (_currentDirection != direction) {
      _currentDirection = direction;
      widget.onDirectionChanged(direction);
    }
  }

  void _handleRelease() {
    _currentDirection = null;
    widget.onDirectionReleased();
  }

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 60;
    const double spacing = 4;
    
    return SizedBox(
      width: buttonSize * 3 + spacing * 2,
      height: buttonSize * 3 + spacing * 2,
      child: Stack(
        children: [
          // Фоновый круг
          Center(
            child: Container(
              width: buttonSize * 2.5,
              height: buttonSize * 2.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
                border: Border.all(
                  color: Colors.grey.shade700,
                  width: 2,
                ),
              ),
            ),
          ),
          
          // Вверх
          Positioned(
            left: buttonSize + spacing,
            top: 0,
            child: _DirectionButton(
              direction: Direction.up,
              icon: Icons.keyboard_arrow_up,
              isActive: _currentDirection == Direction.up,
              onPressed: () => _handleDirection(Direction.up),
              onReleased: _handleRelease,
              size: buttonSize,
            ),
          ),
          
          // Влево
          Positioned(
            left: 0,
            top: buttonSize + spacing,
            child: _DirectionButton(
              direction: Direction.left,
              icon: Icons.keyboard_arrow_left,
              isActive: _currentDirection == Direction.left,
              onPressed: () => _handleDirection(Direction.left),
              onReleased: _handleRelease,
              size: buttonSize,
            ),
          ),
          
          // Центральная точка
          Positioned(
            left: buttonSize + spacing,
            top: buttonSize + spacing,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade600, width: 1),
              ),
              child: const Center(
                child: Icon(
                  Icons.gamepad,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Вправо
          Positioned(
            right: 0,
            top: buttonSize + spacing,
            child: _DirectionButton(
              direction: Direction.right,
              icon: Icons.keyboard_arrow_right,
              isActive: _currentDirection == Direction.right,
              onPressed: () => _handleDirection(Direction.right),
              onReleased: _handleRelease,
              size: buttonSize,
            ),
          ),
          
          // Вниз
          Positioned(
            left: buttonSize + spacing,
            bottom: 0,
            child: _DirectionButton(
              direction: Direction.down,
              icon: Icons.keyboard_arrow_down,
              isActive: _currentDirection == Direction.down,
              onPressed: () => _handleDirection(Direction.down),
              onReleased: _handleRelease,
              size: buttonSize,
            ),
          ),
        ],
      ),
    );
  }
}

/// Кнопка направления D-Pad
class _DirectionButton extends StatelessWidget {
  final Direction direction;
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final double size;

  const _DirectionButton({
    required this.direction,
    required this.icon,
    required this.isActive,
    required this.onPressed,
    required this.onReleased,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased(),
      onTapCancel: onReleased,
      onPanEnd: (_) => onReleased(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [Colors.amber.shade600, Colors.amber.shade800]
                : [Colors.grey.shade700, Colors.grey.shade900],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.amber : Colors.grey.shade600,
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey.shade400,
          size: size * 0.6,
        ),
      ),
    );
  }
}

/// Кнопки действий (огонь)
class ActionButtons extends StatefulWidget {
  final VoidCallback onFire;
  final VoidCallback onPause;

  const ActionButtons({
    super.key,
    required this.onFire,
    required this.onPause,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool _isFirePressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Большая кнопка огня
        GestureDetector(
          onTapDown: (_) {
            setState(() => _isFirePressed = true);
            widget.onFire();
          },
          onTapUp: (_) => setState(() => _isFirePressed = false),
          onTapCancel: () => setState(() => _isFirePressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: _isFirePressed
                    ? [Colors.red.shade400, Colors.red.shade800]
                    : [Colors.red.shade600, Colors.red.shade900],
              ),
              border: Border.all(
                color: _isFirePressed ? Colors.orange : Colors.red.shade400,
                width: 3,
              ),
              boxShadow: _isFirePressed
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(3, 3),
                      ),
                    ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: _isFirePressed ? Colors.yellow : Colors.orange,
                    size: 36,
                  ),
                  Text(
                    'FIRE',
                    style: TextStyle(
                      color: _isFirePressed ? Colors.yellow : Colors.orange.shade200,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Кнопка паузы
class PauseButton extends StatelessWidget {
  final VoidCallback onPause;

  const PauseButton({
    super.key,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPause,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade800.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade600, width: 2),
        ),
        child: const Icon(
          Icons.pause,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

