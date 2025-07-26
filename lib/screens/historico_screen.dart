import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/compra.dart';
import '../models/usuario.dart';
import 'editar_compra_screen.dart';

class HistoricoScreen extends StatefulWidget {
  final Usuario usuario;
  const HistoricoScreen({super.key, required this.usuario});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final dbHelper = DatabaseHelper();
  Map<String, List<Compra>> comprasPorMercado = {};

  @override
  void initState() {
    super.initState();
    carregarCompras();
  }

  Future<void> carregarCompras() async {
    final compras = await dbHelper.getComprasPorUsuario(widget.usuario.id!);

    // Agrupa por supermercado
    final Map<String, List<Compra>> agrupado = {};
    for (var compra in compras) {
      agrupado.putIfAbsent(compra.nomeSupermercado, () => []);
      agrupado[compra.nomeSupermercado]!.add(compra);
    }

    // Ordena cada grupo por data (desc)
    for (var lista in agrupado.values) {
      lista.sort((a, b) => b.data.compareTo(a.data));
    }

    setState(() {
      comprasPorMercado = agrupado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Compras')),
      body: comprasPorMercado.isEmpty
          ? const Center(child: Text('Nenhuma compra registrada.'))
          : ListView(
              children: comprasPorMercado.entries.map((entry) {
                final mercado = entry.key;
                final compras = entry.value;
                return ExpansionTile(
                  title: Text(
                    mercado,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: compras.map((compra) {
                    return ListTile(
                      title: Text('Data: ${compra.data.substring(0, 10)}'),
                      subtitle: Text(
                        'Qtd: ${compra.quantidade} - R\$ ${compra.precoTotalProduto.toStringAsFixed(2)}',
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total: R\$ ${compra.precoTotalCompra.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.orange,
                                ),
                                onPressed: () async {
                                  final atualizado = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditarCompraScreen(compra: compra),
                                    ),
                                  );
                                  if (atualizado == true) {
                                    carregarCompras(); // recarrega o histórico
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirmar = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Confirmar exclusão'),
                                      content: const Text(
                                        'Você quer mesmo excluir essa compra?',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancelar'),
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                        ),
                                        TextButton(
                                          child: const Text('Excluir'),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmar == true) {
                                    await dbHelper.deleteCompra(compra.id!);
                                    carregarCompras();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }
}
