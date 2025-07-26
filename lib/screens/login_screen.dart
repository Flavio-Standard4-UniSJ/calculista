import '../utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/usuario.dart';
import '../utils/encryption.dart';
import 'supermercado_screen.dart'; // próxima tela

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper();

  Future<void> _fazerLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final senhaCriptografada = encryptPassword(_senhaController.text.trim());

      final usuario = await dbHelper.loginUsuario(email, senhaCriptografada);

      if (usuario != null) {
        // ⬇️ Aqui você salva o ID do usuário no SharedPreferences
        await SharedPrefs.salvarUsuarioLogado(usuario.id!);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login bem-sucedido')));

        // ⬇️ Redireciona para a próxima tela (ex: supermercado)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SupermercadoScreen(usuario: usuario),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail ou senha inválidos')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o e-mail' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.length < 6 ? 'Senha inválida' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Entrar'),
                onPressed: _fazerLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
