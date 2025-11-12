import 'package:flutter/material.dart';

class ParallaxLobby extends StatefulWidget {
  const ParallaxLobby({super.key});

  @override
  State<ParallaxLobby> createState() => _ParallaxLobbyState();
}

class _ParallaxLobbyState extends State<ParallaxLobby>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 100000, period: const Duration(minutes: 5));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value; // tiempo
        return Stack(
          fit: StackFit.expand,
          children: [
            _layer('assets/images/lobby/bg_layer_0.png', t * 0.1),
            _layer('assets/images/lobby/bg_layer_1.png', t * 0.3),
            _layer('assets/images/lobby/bg_layer_2.png', t * 0.6),
            _layer('assets/images/lobby/fg_candles.png', t * 0.9),
          ],
        );
      },
    );
  }

  Widget _layer(String asset, double offset) {
    // Scroll infinito horizontal “fake”
    final dx = -(offset % 1.0);
    return FractionalTranslation(
      translation: Offset(dx, 0),
      child: Image.asset(asset, fit: BoxFit.cover),
    );
  }
}
