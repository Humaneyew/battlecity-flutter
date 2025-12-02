import 'package:flutter/material.dart';

/// Главное меню игры в стиле оригинального Battle City
class MainMenu extends StatefulWidget {
  final VoidCallback onStartSingle;
  final VoidCallback onStartDouble;

  const MainMenu({
    super.key,
    required this.onStartSingle,
    required this.onStartDouble,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  int _selectedOption = 0;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  late AnimationController _tankController;
  late Animation<double> _tankAnimation;

  @override
  void initState() {
    super.initState();
    
    // Анимация мигания
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_blinkController);
    
    // Анимация танка-курсора
    _tankController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _tankAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _tankController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _tankController.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    setState(() {
      _selectedOption = index;
    });
    _tankController.forward(from: 0);
  }

  void _confirmSelection() {
    if (_selectedOption == 0) {
      widget.onStartSingle();
    } else {
      widget.onStartDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          const Spacer(flex: 2),
          
          // Логотип BATTLE CITY
          _buildLogo(),
          
          const Spacer(flex: 1),
          
          // Меню опций
          _buildMenuOptions(),
          
          const Spacer(flex: 2),
          
          // Копирайт
          _buildCopyright(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Танки сверху (декоративные)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTankIcon(Colors.green),
            const SizedBox(width: 20),
            _buildTankIcon(Colors.amber),
            const SizedBox(width: 20),
            _buildTankIcon(Colors.red),
          ],
        ),
        const SizedBox(height: 30),
        
        // BATTLE
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.red, Colors.orange, Colors.yellow],
          ).createShader(bounds),
          child: const Text(
            'BATTLE',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 8,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ),
        
        // CITY
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.yellow, Colors.orange, Colors.red],
          ).createShader(bounds),
          child: const Text(
            'CITY',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 16,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTankIcon(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.local_shipping,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: [
        _buildMenuItem(0, '1 PLAYER'),
        const SizedBox(height: 20),
        _buildMenuItem(1, '2 PLAYERS'),
      ],
    );
  }

  Widget _buildMenuItem(int index, String text) {
    final isSelected = _selectedOption == index;
    
    return GestureDetector(
      onTap: () {
        _selectOption(index);
        _confirmSelection();
      },
      child: AnimatedBuilder(
        animation: _blinkAnimation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Танк-курсор
              AnimatedOpacity(
                opacity: isSelected ? _blinkAnimation.value : 0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 20),
                  child: CustomPaint(
                    painter: TankCursorPainter(),
                  ),
                ),
              ),
              
              // Текст пункта меню
              Text(
                text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  letterSpacing: 4,
                ),
              ),
              
              // Пустое место для симметрии
              const SizedBox(width: 50),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCopyright() {
    return Column(
      children: [
        Text(
          'FLUTTER REMAKE',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '© 2024',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

/// Рисует танк-курсор для меню
class TankCursorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    
    // Корпус танка
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.3, size.width * 0.6, size.height * 0.5),
      paint,
    );
    
    // Дуло (направлено вправо)
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.45, size.width * 0.4, size.height * 0.1),
      paint,
    );
    
    // Гусеницы
    paint.color = Colors.amber.shade800;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.2, size.width * 0.7, size.height * 0.15),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.75, size.width * 0.7, size.height * 0.15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

