import 'package:flutter/material.dart';

class EquipoCard extends StatelessWidget {
  final String nombre;
  final String tipo;
  final String rareza;
  final int poder;
  final VoidCallback onEquipar;

  const EquipoCard({
    super.key,
    required this.nombre,
    required this.tipo,
    required this.rareza,
    required this.poder,
    required this.onEquipar,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (rareza) {
      'épico' => Colors.deepPurpleAccent,
      'raro' => Colors.cyanAccent,
      _ => Colors.grey.shade300,
    };

    return Card(
      color: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(nombre, style: TextStyle(color: color)),
        subtitle: Text('Tipo: $tipo  |  Poder: $poder'),
        trailing: ElevatedButton(
          onPressed: onEquipar,
          child: const Text('Equipar'),
        ),
      ),
    );
  }
}
