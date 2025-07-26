class Usuario {
  int? id;
  String nomeCompleto;
  String email;
  String senha; // já criptografada

  Usuario({
    this.id,
    required this.nomeCompleto,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome_completo': nomeCompleto,
      'email': email,
      'senha': senha,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nomeCompleto: map['nome_completo'],
      email: map['email'],
      senha: map['senha'],
    );
  }
}
