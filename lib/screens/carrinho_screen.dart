import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/produto.dart';
import '../models/compra.dart';
import '../db/database_helper.dart';

class CarrinhoScreen extends StatefulWidget {
  final Usuario usuario;
  final String nomeSupermercado;

  const CarrinhoScreen({
    super.key,
    required this.usuario,
    required this.nomeSupermercado,
  });

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeProdutoController = TextEditingController();
  final _marcaController = TextEditingController();
  final _precoUnitarioController = TextEditingController();
  final _quantidadeController = TextEditingController();

  final dbHelper = DatabaseHelper();

  List<Compra> carrinho = [];
  double totalCompra = 0.0;

  void _adicionarItem() async {
    if (_formKey.currentState!.validate()) {
      final nomeProduto = _nomeProdutoController.text.trim();
      final marca = _marcaController.text.trim();
      final precoUnitario = double.parse(_precoUnitarioController.text);
      final quantidade = int.parse(_quantidadeController.text);
      final precoTotalProduto = precoUnitario * quantidade;

      // Salva produto (se for novo)
      final produto = Produto(
        nome: nomeProduto,
        marca: marca,
        preco: precoUnitario,
      );
      final produtoId = await dbHelper.insertProduto(produto);

      // Cria item da compra (em memória primeiro)
      final dataAtual = DateTime.now().toIso8601String();

      final item = Compra(
        usuarioId: widget.usuario.id!,
        produtoId: produtoId,
        nomeSupermercado: widget.nomeSupermercado,
        quantidade: quantidade,
        precoUnitario: precoUnitario,
        precoTotalProduto: precoTotalProduto,
        precoTotalCompra: 0.0, // será atualizado depois
        data: dataAtual,
      );

      setState(() {
        carrinho.add(item);
        totalCompra += precoTotalProduto;
      });

      // Limpa os campos
      _nomeProdutoController.clear();
      _marcaController.clear();
      _precoUnitarioController.clear();
      _quantidadeController.clear();
    }
  }

  Future<void> _finalizarCompra() async {
    final dataAtual = DateTime.now().toIso8601String();
    for (var item in carrinho) {
      item.precoTotalCompra = totalCompra;
      item.data = dataAtual;
      await dbHelper.insertCompra(item);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Compra finalizada! Total: R\$ ${totalCompra.toStringAsFixed(2)}',
        ),
      ),
    );

    setState(() {
      carrinho.clear();
      totalCompra = 0.0;
    });

    Navigator.pop(context); // volta para supermercado
  }

  @override
  void dispose() {
    _nomeProdutoController.dispose();
    _marcaController.dispose();
    _precoUnitarioController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho de Compras')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.add_shopping_cart,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _precoUnitarioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Preço unitário (R\$)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || double.tryParse(value) == null
                        ? 'Digite um valor válido'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _quantidadeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || int.tryParse(value) == null
                        ? 'Digite uma quantidade válida'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nomeProdutoController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do produto',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Informe o nome'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _marcaController,
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Produto'),
                    onPressed: _adicionarItem,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Text(
              'Itens adicionados:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...carrinho.map(
              (item) => ListTile(
                title: Text('Produto ID: ${item.produtoId}'),
                subtitle: Text(
                  'Qtd: ${item.quantidade} x R\$${item.precoUnitario.toStringAsFixed(2)}',
                ),
                trailing: Text(
                  'R\$ ${item.precoTotalProduto.toStringAsFixed(2)}',
                ),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text(
                'Total da Compra',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                'R\$ ${totalCompra.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Finalizar Compra'),
              onPressed: carrinho.isEmpty ? null : _finalizarCompra,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
