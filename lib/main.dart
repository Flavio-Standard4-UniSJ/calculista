import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db/database_helper.dart';
import 'models/usuario.dart';
import 'screens/supermercado_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';
import 'utils/shared_prefs.dart';

void main() {
  runApp(const CalculistaApp());
}

class CalculistaApp extends StatelessWidget {
  const CalculistaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculista',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      debugShowCheckedModeBanner: false,
      home: const VerificacaoLogin(),
    );
  }
}

class VerificacaoLogin extends StatelessWidget {
  const VerificacaoLogin({super.key});

  Future<Widget> _verificarUsuario() async {
    final usuarioId = await SharedPrefs.obterUsuarioLogado();

    if (usuarioId != null) {
      final db = DatabaseHelper();
      final dbUser = await db.loginUsuarioPorId(usuarioId);
      if (dbUser != null) {
        return SupermercadoScreen(usuario: dbUser);
      }
    }
    return const TelaInicial();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _verificarUsuario(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return snapshot.data!;
        }
      },
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calculate_outlined, size: 100, color: Colors.teal),
            const SizedBox(height: 32),
            const Text(
              'Calculista',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Criar Conta'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CadastroScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
