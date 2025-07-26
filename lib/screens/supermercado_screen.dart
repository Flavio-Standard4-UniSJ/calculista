import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'carrinho_screen.dart';
import 'historico_screen.dart';
import '../utils/shared_prefs.dart';
import '../main.dart';

class SupermercadoScreen extends StatefulWidget {
  final Usuario usuario;

  const SupermercadoScreen({super.key, required this.usuario});

  @override
  State<SupermercadoScreen> createState() => _SupermercadoScreenState();
}

class _SupermercadoScreenState extends State<SupermercadoScreen> {
  final _supermercadoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _supermercadoController.dispose();
    super.dispose();
  }

  void _iniciarCompra() {
    if (_formKey.currentState!.validate()) {
      final nomeSupermercado = _supermercadoController.text.trim();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CarrinhoScreen(
            usuario: widget.usuario,
            nomeSupermercado: nomeSupermercado,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Compra')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.store, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              TextFormField(
                controller: _supermercadoController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Supermercado',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o nome do supermercado'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Iniciar Compra'),
                onPressed: _iniciarCompra,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('Ver Histórico'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoricoScreen(usuario: widget.usuario),
                    ),
                  );
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sair'),
                onPressed: () async {
                  await SharedPrefs.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaInicial()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
