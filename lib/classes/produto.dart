class Produto {
  int id;
  String descricao;
  double valor;

  Produto({
    this.id,
    this.descricao,
    this.valor,
  });

  Produto.fromMap(Map<String, dynamic> mapProduto) {
    id = mapProduto['id'];
    descricao = mapProduto['descricao'];
    valor = mapProduto['valor'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
    };
  }
}