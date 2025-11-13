import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../services/supabase_service.dart';
import 'package:vesperum/game/vesperum_battle.dart';

class ModeHistoriaScreen extends StatefulWidget {
  final String nombreJugador;
  const ModeHistoriaScreen({super.key, required this.nombreJugador});

  @override
  State<ModeHistoriaScreen> createState() => _ModeHistoriaScreenState();
}

class _ModeHistoriaScreenState extends State<ModeHistoriaScreen>
    with SingleTickerProviderStateMixin {
  String _textoActual = "";
  final String _textoHistoria = """
Bajo la luna carmesí, los ecos de una guerra olvidada vuelven a resonar.

El cazador despierta entre cenizas y sombras...

Su misión ha comenzado.
""";

  bool _textoCompletado = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _iniciarMusica();
    _mostrarTextoPocoAPoco();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    FlameAudio.bgm.stop();
    super.dispose();
  }

  /// 🎵 Inicializa y reproduce la música de fondo
  Future<void> _iniciarMusica() async {
    try {
      await FlameAudio.bgm.initialize();
      await FlameAudio.bgm.play('requiem_of_eclipse.mp3', volume: 0.5);
    } catch (e) {
      debugPrint("⚠️ No se pudo reproducir la música: $e");
    }
  }

  /// 🕯️ Muestra el texto letra por letra con efecto de escritura
  Future<void> _mostrarTextoPocoAPoco() async {
    for (int i = 0; i < _textoHistoria.length; i++) {
      await Future.delayed(const Duration(milliseconds: 45));
      if (!mounted) return;
      setState(() {
        _textoActual = _textoHistoria.substring(0, i + 1);
      });
    }
    if (!mounted) return;
    setState(() => _textoCompletado = true);
    _fadeController.forward();
  }

  /// ⚔️ Inicia el modo historia y navega a la escena de combate
  Future<void> _comenzarCaza() async {
    try {
      await Supa.client
          .from('progreso_historia')
          .upsert({'nivel_actual': 1, 'completado': false});

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VesperumBattle(nombreJugador: widget.nombreJugador),
        ),
      );
    } catch (e) {
      debugPrint("⚠️ Error al iniciar la caza: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al iniciar la caza. Intenta nuevamente.'),
          backgroundColor: Colors.redAccent.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌘 Fondo de la escena de introducción
          Image.asset(
            'assets/images/luna_roja.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.55),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _textoActual,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.4,
                    fontFamily: 'PressStart2P', // ✅ fuente pixel art
                  ),
                ),
                const SizedBox(height: 40),
                if (_textoCompletado)
                  FadeTransition(
                    opacity: _fadeController,
                    child: Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.shade700,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _comenzarCaza,
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text(
                          "Comenzar la caza",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'PressStart2P',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
