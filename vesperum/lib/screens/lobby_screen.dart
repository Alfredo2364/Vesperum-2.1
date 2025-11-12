import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/parallax_lobby.dart';
import '../widgets/perfil_panel.dart';
// import '../services/supabase_service.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _music = AudioPlayer();
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _playMusic();
  }

  Future<void> _loadUser() async {
    // final data = await Supa.fetchUserSummary();  // cuando conectemos
    // Mock por ahora:
    final data = await Future.value({
      'nombre': 'Lucien Voss',
      'esencias': 742,
      'estrellas': 9,
      'record_noche_eterna': '04:35',
      'nivel': 3,
    });
    if (mounted) setState(() => _user = data);
  }

  Future<void> _playMusic() async {
    try {
      await _music.setAsset('assets/audio/requiem_eclipse.ogg');
      await _music.setLoopMode(LoopMode.one);
      await _music.play();
    } catch (_) {/*ignoramos en dev*/}
  }

  @override
  void dispose() {
    _music.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      body: Stack(
        children: [
          const ParallaxLobby(),
          // Filtro oscuro sutil para leer mejor
          Container(color: Colors.black.withOpacity(0.25)),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  nombre: user?['nombre'] ?? '...',
                  esencias: user?['esencias'] ?? 0,
                  estrellas: user?['estrellas'] ?? 0,
                  onTapNombre: () async {
                    final newName = await showModalBottomSheet<String>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.black87,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => PerfilPanel(user: user ?? {}),
                    );
                    if (newName != null && newName.isNotEmpty) {
                      setState(() => _user!['nombre'] = newName);
                    }
                  },
                ),
                const Spacer(),
                // “Representación” del personaje (NO abre perfil)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      // Aquí luego pintaremos el sprite animado (Flame).
                      // Por ahora, una imagen/placeholder:
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withOpacity(0.25),
                          border: Border.all(color: Colors.white24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Tu personaje',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Equipo visible aquí (arma/armadura/skin)',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _MenuButtons(
                  onHistoria: () {/* Navigator.pushNamed(context, '/historia'); */},
                  onNocheEterna: () {/* Navigator.pushNamed(context, '/nocheEterna'); */},
                  onTienda: () {/* Navigator.pushNamed(context, '/tienda'); */},
                  onPuntuaciones: () {/* Navigator.pushNamed(context, '/puntuaciones'); */},
                  onCinematicas: () {/* Navigator.pushNamed(context, '/cinematicas'); */},
                  onConfig: () {/* Navigator.pushNamed(context, '/config'); */},
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String nombre;
  final int esencias;
  final int estrellas;
  final VoidCallback onTapNombre;

  const _TopBar({
    required this.nombre,
    required this.esencias,
    required this.estrellas,
    required this.onTapNombre,
  });

  @override
  Widget build(BuildContext context) {
    final chipStyle = Theme.of(context).textTheme.labelSmall;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTapNombre, // << SOLO aquí se abre el perfil
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 10,
                    backgroundImage: AssetImage('assets/images/ui/avatar_default.png'),
                  ),
                  const SizedBox(width: 8),
                  Text(nombre, style: chipStyle),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
          ),
          const Spacer(),
          _Chip(icon: '🩸', text: esencias.toString()),
          const SizedBox(width: 8),
          _Chip(icon: '⭐', text: estrellas.toString()),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String icon;
  final String text;
  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Text('$icon $text', style: style),
    );
  }
}

class _MenuButtons extends StatelessWidget {
  final VoidCallback onHistoria;
  final VoidCallback onNocheEterna;
  final VoidCallback onTienda;
  final VoidCallback onPuntuaciones;
  final VoidCallback onCinematicas;
  final VoidCallback onConfig;

  const _MenuButtons({
    required this.onHistoria,
    required this.onNocheEterna,
    required this.onTienda,
    required this.onPuntuaciones,
    required this.onCinematicas,
    required this.onConfig,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn(String emoji, String text, VoidCallback onTap) {
      return SizedBox(
        width: 260,
        child: FilledButton(
          onPressed: onTap,
          child: Text('$emoji  $text'),
        ),
      );
    }

    return Column(
      children: [
        btn('🧭', 'Historia', onHistoria),
        const SizedBox(height: 8),
        btn('💀', 'Noche Eterna', onNocheEterna),
        const SizedBox(height: 8),
        btn('🏪', 'Tienda', onTienda),
        const SizedBox(height: 8),
        btn('🏆', 'Puntuaciones', onPuntuaciones),
        const SizedBox(height: 8),
        btn('🎬', 'Cinemáticas', onCinematicas),
        const SizedBox(height: 8),
        btn('⚙️', 'Configuración', onConfig),
      ],
    );
  }
}
