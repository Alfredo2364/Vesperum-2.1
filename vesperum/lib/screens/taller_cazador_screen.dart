import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/equipo_card.dart';
import '../widgets/stat_bar.dart';

class TallerCazadorScreen extends StatefulWidget {
  final String nombreJugador;
  const TallerCazadorScreen({super.key, required this.nombreJugador});

  @override
  State<TallerCazadorScreen> createState() => _TallerCazadorScreenState();
}

class _TallerCazadorScreenState extends State<TallerCazadorScreen> {
  List<Map<String, dynamic>> _armas = [];
  List<Map<String, dynamic>> _armaduras = [];
  String? _armaActual;
  String? _armaduraActual;
  int ataque = 0, defensa = 0, vitalidad = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final armas = await Supa.getArmas();
    final armaduras = await Supa.getArmaduras();
    final equipo = await Supa.getEquipamiento(widget.nombreJugador);

    setState(() {
      _armas = armas;
      _armaduras = armaduras;
      _armaActual = equipo?['armas']?['nombre'];
      _armaduraActual = equipo?['armaduras']?['nombre'];
      ataque = equipo?['armas']?['ataque'] ?? 0;
      defensa = equipo?['armaduras']?['defensa'] ?? 0;
      vitalidad = equipo?['armaduras']?['vitalidad'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taller del Cazador'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 ${widget.nombreJugador}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            StatBar(label: 'Ataque', value: ataque, icon: Icons.flash_on),
            StatBar(label: 'Defensa', value: defensa, icon: Icons.shield),
            StatBar(label: 'Vitalidad', value: vitalidad, icon: Icons.favorite),
            const Divider(height: 32, thickness: 1, color: Colors.white24),
            Text('⚔️ Armas', style: Theme.of(context).textTheme.titleSmall),
            ..._armas.map((a) => EquipoCard(
              nombre: a['nombre'],
              tipo: 'Arma',
              rareza: a['rareza'],
              poder: a['ataque'],
              onEquipar: () async {
                await Supa.setEquipamiento(nombreUsuario: widget.nombreJugador, armaId: a['id']);
                _loadData();
              },
            )),
            const Divider(height: 32, thickness: 1, color: Colors.white24),
            Text('🛡️ Armaduras', style: Theme.of(context).textTheme.titleSmall),
            ..._armaduras.map((a) => EquipoCard(
              nombre: a['nombre'],
              tipo: 'Armadura',
              rareza: a['rareza'],
              poder: a['defensa'],
              onEquipar: () async {
                await Supa.setEquipamiento(nombreUsuario: widget.nombreJugador, armaduraId: a['id']);
                _loadData();
              },
            )),
          ],
        ),
      ),
    );
  }
}
