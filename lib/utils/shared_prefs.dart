import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String keyUserId = 'usuario_id';

  static Future<void> salvarUsuarioLogado(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyUserId, usuarioId);
  }

  static Future<int?> obterUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyUserId);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUserId);
  }
}
