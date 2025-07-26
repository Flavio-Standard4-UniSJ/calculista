class Produto {
  int? id;
  String nome;
  String marca;
  double preco;

  Produto({
    this.id,
    required this.nome,
    required this.marca,
    required this.preco,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome_do_produto': nome,
      'marca_do_produto': marca,
      'preco_do_produto': preco,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome_do_produto'],
      marca: map['marca_do_produto'],
      preco: map['preco_do_produto'],
    );
  }
}
