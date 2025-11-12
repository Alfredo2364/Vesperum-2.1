import 'package:flutter/material.dart';

class PerfilPanel extends StatefulWidget {
  final Map<String, dynamic> user;
  const PerfilPanel({super.key, required this.user});

  @override
  State<PerfilPanel> createState() => _PerfilPanelState();
}

class _PerfilPanelState extends State<PerfilPanel> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user['nombre'] as String? ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styleTitle = Theme.of(context).textTheme.titleMedium;
    final styleBody = Theme.of(context).textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 4, width: 50, decoration: BoxDecoration(
            color: Colors.white24, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 12),
          Text('Registro del Cazador', style: styleTitle),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: const AssetImage('assets/images/ui/avatar_default.png'),
                foregroundColor: Colors.transparent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Tu nombre en el ranking',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final newName = _nameCtrl.text.trim();
                  if (newName.isEmpty) return;

                  // TODO: Validar nombre duplicado en Supabase y actualizar:
                  // await Supa.client!.from('users').update({'nombre': newName}).eq('id', userId);
                  // await Supa.client!.from('ranking').update({'nombre_usuario': newName}).eq('user_id', userId);

                  if (context.mounted) {
                    Navigator.pop(context, newName);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nivel: ${widget.user['nivel']}', style: styleBody),
              Text('⭐ ${widget.user['estrellas']} estrellas', style: styleBody),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🩸 Esencias: ${widget.user['esencias']}', style: styleBody),
              Text('Récord Noche Eterna: ${widget.user['record_noche_eterna']}', style: styleBody),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () {
              // TODO: Navegar al Taller del Cazador (editar arma/armadura/skin)
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const TallerCazadorScreen()));
            },
            child: const Text('Editar personaje'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
