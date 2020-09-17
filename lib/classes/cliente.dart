class Cliente {
  int id, sincronizado;
  String cpfcnpj, nome, email, telefone;

  Cliente({
    this.id,
    this.cpfcnpj,
    this.nome,
    this.email,
    this.telefone,
    this.sincronizado,
  });

  Cliente.fromMap(Map<String, dynamic> mapCliente) {
    id = mapCliente['id'];
    cpfcnpj = mapCliente['cpf_cnpj'];
    nome = mapCliente['nome'];
    email = mapCliente['email'];
    telefone = mapCliente['telefone'];
    sincronizado = mapCliente['sincronizado'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cpf_cnpj': cpfcnpj,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'sincronizado': sincronizado,
    };
  }
}