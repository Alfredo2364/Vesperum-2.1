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

  // 🩸 Equipamiento base
  String armaActual = "Esperando elección...";
  String armaduraActual = "Armadura de cuero liviana";

  int ataque = 0;
  int defensa = 1;
  int vitalidad = 0;

  bool _armaSeleccionada = false;

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

      armaActual = equipo?['armas']?['nombre'] ?? armaActual;
      armaduraActual = equipo?['armaduras']?['nombre'] ?? armaduraActual;

      ataque = equipo?['armas']?['ataque'] ?? ataque;
      defensa = equipo?['armaduras']?['defensa'] ?? defensa;
      vitalidad = equipo?['armaduras']?['vitalidad'] ?? vitalidad;

      _armaSeleccionada = equipo?['armas']?['nombre'] != null;
    });

    // Mostrar selección de arma si no hay una asignada
    if (!_armaSeleccionada) {
      Future.delayed(const Duration(milliseconds: 500), _mostrarSeleccionArma);
    }
  }

  void _mostrarSeleccionArma() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            "Elige tu arma inicial ⚔️",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _armaOpcion("Látigo de Sangre", 4, "Alta velocidad", 1),
              const SizedBox(height: 10),
              _armaOpcion("Espada Oxidada", 5, "Golpe pesado", 2),
            ],
          ),
        );
      },
    );
  }

  Widget _armaOpcion(String nombre, int ataqueBase, String desc, int idArma) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
      onPressed: () async {
        Navigator.pop(context);
        setState(() {
          armaActual = nombre;
          ataque = ataqueBase;
          _armaSeleccionada = true;
        });

        // Guardar elección en Supabase
        await Supa.setEquipamiento(
          nombreUsuario: widget.nombreJugador,
          armaId: idArma, // ID de la tabla armas
          armaduraId: 1,  // ID de la armadura base
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Has elegido el $nombre 🩸"),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Column(
        children: [
          Text(nombre,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Ataque: $ataqueBase | $desc",
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taller del Cazador'),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👤 ${widget.nombreJugador}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            StatBar(label: 'Ataque', value: ataque, icon: Icons.flash_on),
            StatBar(label: 'Defensa', value: defensa, icon: Icons.shield),
            StatBar(label: 'Vitalidad', value: vitalidad, icon: Icons.favorite),
            const Divider(height: 32, thickness: 1, color: Colors.white24),
            Text('⚔️ Armas',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.redAccent)),
            ..._armas.map((a) => EquipoCard(
                  nombre: a['nombre'],
                  tipo: 'Arma',
                  rareza: a['rareza'],
                  poder: a['ataque'],
                  onEquipar: () async {
                    await Supa.setEquipamiento(
                        nombreUsuario: widget.nombreJugador, armaId: a['id']);
                    _loadData();
                  },
                )),
            const Divider(height: 32, thickness: 1, color: Colors.white24),
            Text('🛡️ Armaduras',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.lightBlueAccent)),
            ..._armaduras.map((a) => EquipoCard(
                  nombre: a['nombre'],
                  tipo: 'Armadura',
                  rareza: a['rareza'],
                  poder: a['defensa'],
                  onEquipar: () async {
                    await Supa.setEquipamiento(
                        nombreUsuario: widget.nombreJugador, armaduraId: a['id']);
                    _loadData();
                  },
                )),
          ],
        ),
      ),
    );
  }
}
