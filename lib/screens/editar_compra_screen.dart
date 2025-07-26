import 'package:flutter/material.dart';
import '../models/compra.dart';
import '../db/database_helper.dart';

class EditarCompraScreen extends StatefulWidget {
  final Compra compra;

  const EditarCompraScreen({super.key, required this.compra});

  @override
  State<EditarCompraScreen> createState() => _EditarCompraScreenState();
}

class _EditarCompraScreenState extends State<EditarCompraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _precoUnitarioController = TextEditingController();

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _quantidadeController.text = widget.compra.quantidade.toString();
    _precoUnitarioController.text = widget.compra.precoUnitario.toStringAsFixed(
      2,
    );
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novaQuantidade = int.parse(_quantidadeController.text);
      final novoPrecoUnitario = double.parse(_precoUnitarioController.text);
      final novoPrecoProduto = novaQuantidade * novoPrecoUnitario;

      final compraAtualizada = Compra(
        id: widget.compra.id,
        usuarioId: widget.compra.usuarioId,
        produtoId: widget.compra.produtoId,
        nomeSupermercado: widget.compra.nomeSupermercado,
        quantidade: novaQuantidade,
        precoUnitario: novoPrecoUnitario,
        precoTotalProduto: novoPrecoProduto,
        precoTotalCompra: novoPrecoProduto, // pode ser ajustado com soma futura
        data: widget.compra.data,
      );

      await dbHelper.updateCompra(compraAtualizada);
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _precoUnitarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Compra')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null
                    ? 'Valor inválido'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoUnitarioController,
                decoration: const InputDecoration(labelText: 'Preço unitário'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                    ? 'Valor inválido'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
