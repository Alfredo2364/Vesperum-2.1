import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  static SupabaseClient? client;

  static Future<void> init() async {
    // TODO: reemplaza con tus creds
    await Supabase.initialize(
      url: 'postgresql://postgres:[AoVfred030702.]@db.gjnytzezoumsdkxorjre.supabase.co:5432/postgres',
      anonKey: 'AoVfred030702.',
    );
    client = Supabase.instance.client;
  }

  // Mock de usuario para lobby mientras no conectamos
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
