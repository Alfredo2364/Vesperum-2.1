import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  static late SupabaseClient client;

  static Future<void> init() async {
    // ⚙️ Inicialización de Supabase
    await Supabase.initialize(
      url: 'https://gjnytzezoumsdkxorjre.supabase.co', // ✅ URL del proyecto
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdqbnl0emV6b3Vtc2RreG9yanJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MDg5NDAsImV4cCI6MjA3ODQ4NDk0MH0.WFNX7N40PW74kF2lRDiyQPANxvVfQSqUkDmEQFZr6Tc', // ✅ Clave pública (NO contraseña)
    );

    client = Supabase.instance.client;
  }

  // ==========================================================
  // 🧩 FUNCIONES DE USUARIO
  // ==========================================================

  static Future<Map<String, dynamic>?> fetchUser(String nombre) async {
    return await client
        .from('users')
        .select()
        .eq('nombre', nombre)
        .maybeSingle();
  }

  static Future<Map<String, dynamic>> registerUser(String nombre) async {
    final existing = await client
        .from('users')
        .select()
        .eq('nombre', nombre)
        .maybeSingle();

    if (existing != null) return existing;

    final inserted = await client
        .from('users')
        .insert({'nombre': nombre})
        .select()
        .single();

    await client.from('ranking').insert({
      'user_id': inserted['id'],
      'nombre_usuario': nombre,
      'puntuacion': 0,
    });

    return inserted;
  }

  static Future<void> updateUserName(String oldName, String newName) async {
    final user = await fetchUser(oldName);
    if (user == null) return;

    await client.from('users').update({'nombre': newName}).eq('id', user['id']);
    await client
        .from('ranking')
        .update({'nombre_usuario': newName})
        .eq('user_id', user['id']);
  }

  static Future<void> saveProgress({
    required String nombre,
    required int nivel,
    required int estrellas,
    required int esencias,
  }) async {
    await client
        .from('users')
        .update({
          'nivel': nivel,
          'estrellas': estrellas,
          'esencias': esencias,
        })
        .eq('nombre', nombre);
  }

  // ==========================================================
  // ⚔️ FUNCIONES DEL TALLER DEL CAZADOR (EQUIPO)
  // ==========================================================

  /// 🔹 Obtener todas las armas disponibles
  static Future<List<Map<String, dynamic>>> getArmas() async {
    final response = await client.from('armas').select();
    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔹 Obtener todas las armaduras disponibles
  static Future<List<Map<String, dynamic>>> getArmaduras() async {
    final response = await client.from('armaduras').select();
    return List<Map<String, dynamic>>.from(response);
  }

  /// 🔹 Obtener el equipamiento actual del jugador
  static Future<Map<String, dynamic>?> getEquipamiento(String nombre) async {
    final user = await fetchUser(nombre);
    if (user == null) return null;

    final result = await client
        .from('equipamiento_actual')
        .select('''
          arma_id,
          armadura_id,
          armas (nombre, ataque),
          armaduras (nombre, defensa, vitalidad)
        ''')
        .eq('user_id', user['id'])
        .maybeSingle();

    return result;
  }

  /// 🔹 Cambiar o asignar equipamiento al jugador
  static Future<void> setEquipamiento({
    required String nombreUsuario,
    int? armaId,
    int? armaduraId,
  }) async {
    final user = await fetchUser(nombreUsuario);
    if (user == null) return;

    final update = <String, dynamic>{};
    if (armaId != null) update['arma_id'] = armaId;
    if (armaduraId != null) update['armadura_id'] = armaduraId;

    await client.from('equipamiento_actual').upsert({
      'user_id': user['id'],
      ...update,
    });
  }

  // ==========================================================
  // 🧠 MOCK DE PRUEBA (SIN CONEXIÓN)
  // ==========================================================

  static Future<Map<String, dynamic>> fetchUserSummaryMock() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return {
      'nombre': 'Lucien Voss',
      'esencias': 742,
      'estrellas': 9,
      'record_noche_eterna': '04:35',
      'nivel': 3,
    };
  }
}
