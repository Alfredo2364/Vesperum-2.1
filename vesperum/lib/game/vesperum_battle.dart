import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart'; // ✅ necesario para TapCallbacks y TapDownEvent
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

class VesperumBattle extends FlameGame with TapCallbacks {
  final String nombreJugador;
  late Player _player;
  late Enemy _enemy;
  late HealthBar _playerHpBar;
  late HealthBar _enemyHpBar;

  VesperumBattle({required this.nombreJugador});

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // ✅ importante en Flame
    await FlameAudio.bgm.initialize();
    await FlameAudio.bgm.play('requiem_of_eclipse.mp3', volume: 0.4);

    // Asegura que el tamaño del juego esté listo
    await Future.delayed(const Duration(milliseconds: 100));

    // 🧍 Jugador
    _player = Player()
      ..position = Vector2(100, size.y - 150)
      ..size = Vector2(64, 64);
    add(_player);

    // 👹 Enemigo
    _enemy = Enemy()
      ..position = Vector2(size.x - 150, size.y - 150)
      ..size = Vector2(64, 64);
    add(_enemy);

    // ❤️ Barras de vida
    _playerHpBar = HealthBar(Vector2(20, 20), Colors.green);
    _enemyHpBar = HealthBar(Vector2(size.x - 220, 20), Colors.red);
    add(_playerHpBar);
    add(_enemyHpBar);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _playerHpBar.updateHealth(_player.health);
    _enemyHpBar.updateHealth(_enemy.health);

    // Si el enemigo muere
    if (_enemy.health <= 0 && !_enemy.isDead) {
      _enemy.isDead = true;
      FlameAudio.play('hit_enemy.wav');
      overlays.add('victory');
    }

    // Si el jugador muere
    if (_player.health <= 0 && !_player.isDead) {
      _player.isDead = true;
      FlameAudio.play('player_hurt.wav');
      overlays.add('defeat');
    }
  }

  // ✅ Flame actual usa TapDownEvent
  @override
  void onTapDown(TapDownEvent event) {
    final tapX = event.localPosition.x;

    // Mitad izquierda = esquivar, derecha = atacar
    if (tapX < size.x / 2) {
      _player.dodge();
    } else {
      _player.attack(_enemy);
    }
  }

  @override
  void onDetach() {
    FlameAudio.bgm.stop();
    super.onDetach();
  }
}

// ===================== 🧛‍♂️ JUGADOR =====================
class Player extends SpriteComponent {
  int health = 100;
  bool isDead = false;
  bool canAttack = true;

  Future<void> attack(Enemy enemy) async {
    if (!canAttack || isDead) return;
    canAttack = false;

    FlameAudio.play('sword_swing.wav');
    if ((position.x - enemy.position.x).abs() < 120) {
      enemy.receiveDamage(20);
    }

    await Future.delayed(const Duration(milliseconds: 700));
    canAttack = true;
  }

  void dodge() {
    if (isDead) return;
    FlameAudio.play('player_hurt.wav');
    position.add(Vector2(-30, 0));
  }

  void receiveDamage(int damage) {
    if (isDead) return;
    health -= damage;
    FlameAudio.play('player_hurt.wav');
    if (health < 0) health = 0;
  }
}

// ===================== 🦇 ENEMIGO =====================
class Enemy extends SpriteComponent {
  int health = 100;
  bool isDead = false;

  void receiveDamage(int damage) {
    if (isDead) return;
    health -= damage;
    if (health < 0) health = 0;
  }

  void attack(Player player) {
    if (isDead) return;
    if ((position.x - player.position.x).abs() < 100) {
      player.receiveDamage(10);
    }
  }
}

// ===================== ❤️ BARRA DE VIDA =====================
class HealthBar extends PositionComponent {
  final int _maxHealth = 100;
  int _currentHealth = 100;
  final Color color;

  HealthBar(Vector2 position, this.color) {
    this.position = position;
    size = Vector2(200, 16);
  }

  void updateHealth(int health) {
    _currentHealth = health.clamp(0, _maxHealth);
  }

  @override
  void render(Canvas canvas) {
    final paintBg = Paint()..color = Colors.grey.shade800;
    final paintHp = Paint()..color = color;

    canvas.drawRect(size.toRect(), paintBg);
    final hpWidth = size.x * (_currentHealth / _maxHealth);
    canvas.drawRect(Rect.fromLTWH(0, 0, hpWidth, size.y), paintHp);
  }
}
