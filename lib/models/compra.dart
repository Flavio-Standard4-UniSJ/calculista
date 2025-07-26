class Compra {
  int? id;
  int usuarioId;
  int produtoId;
  String nomeSupermercado;
  int quantidade;
  double precoUnitario;
  double precoTotalProduto; // quantidade * preço unitário
  double precoTotalCompra; // somado depois de todos os produtos
  String data;

  Compra({
    this.id,
    required this.usuarioId,
    required this.produtoId,
    required this.nomeSupermercado,
    required this.quantidade,
    required this.precoUnitario,
    required this.precoTotalProduto,
    required this.precoTotalCompra,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'produto_id': produtoId,
      'nome_do_supermercado': nomeSupermercado,
      'quantidade': quantidade,
      'preco_unitario': precoUnitario,
      'preco_total_produto': precoTotalProduto,
      'preco_total_compra': precoTotalCompra,
      'data': data,
    };
  }

  factory Compra.fromMap(Map<String, dynamic> map) {
    return Compra(
      id: map['id'],
      usuarioId: map['usuario_id'],
      produtoId: map['produto_id'],
      nomeSupermercado: map['nome_do_supermercado'],
      quantidade: map['quantidade'],
      precoUnitario: map['preco_unitario'],
      precoTotalProduto: map['preco_total_produto'],
      precoTotalCompra: map['preco_total_compra'],
      data: map['data'],
    );
  }
}
