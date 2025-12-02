import 'package:flame_audio/flame_audio.dart';

/// Менеджер звуков игры
class AudioManager {
  bool _initialized = false;
  bool _soundEnabled = true;
  double _volume = 1.0;

  /// Инициализация аудио
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      // Предзагрузка звуков
      await FlameAudio.audioCache.loadAll([
        'bullet_shot.ogg',
        'explosion_1.ogg',
        'explosion_2.ogg',
        'hit.ogg',
        'powerup_appear.ogg',
        'powerup_pick.ogg',
        'stage_start.ogg',
        'game_over.ogg',
        'pause.ogg',
      ]);
      _initialized = true;
    } catch (e) {
      print('Failed to initialize audio: $e');
    }
  }

  /// Воспроизвести звук выстрела
  void playShoot() {
    if (!_soundEnabled) return;
    _playSound('bullet_shot.ogg');
  }

  /// Воспроизвести звук попадания
  void playHit() {
    if (!_soundEnabled) return;
    _playSound('hit.ogg');
  }

  /// Воспроизвести звук взрыва
  void playExplosion({bool big = false}) {
    if (!_soundEnabled) return;
    _playSound(big ? 'explosion_2.ogg' : 'explosion_1.ogg');
  }

  /// Воспроизвести звук появления бонуса
  void playBonusAppear() {
    if (!_soundEnabled) return;
    _playSound('powerup_appear.ogg');
  }

  /// Воспроизвести звук подбора бонуса
  void playBonusPick() {
    if (!_soundEnabled) return;
    _playSound('powerup_pick.ogg');
  }

  /// Воспроизвести звук начала уровня
  void playStageStart() {
    if (!_soundEnabled) return;
    _playSound('stage_start.ogg');
  }

  /// Воспроизвести звук Game Over
  void playGameOver() {
    if (!_soundEnabled) return;
    _playSound('game_over.ogg');
  }

  /// Воспроизвести звук паузы
  void playPause() {
    if (!_soundEnabled) return;
    _playSound('pause.ogg');
  }

  void _playSound(String filename) {
    try {
      FlameAudio.play(filename, volume: _volume);
    } catch (e) {
      // Игнорируем ошибки воспроизведения
    }
  }

  /// Включить/выключить звук
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  /// Установить громкость
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// Звук включен?
  bool get isSoundEnabled => _soundEnabled;

  /// Текущая громкость
  double get volume => _volume;
}

