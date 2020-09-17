const DATABASE_NAME = 'vendas.db';

const CREATE_TABLE_CLIENTE = 'CREATE TABLE cliente('
  + 'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
  + 'cpf_cnpj TEXT, '
  + 'nome TEXT, '
  + 'email TEXT, '
  + 'telefone TEXT, '
  + 'rota INTEGER,'
  + 'sincronizado INTEGER)';

const CREATE_TABLE_PRODUTO = 'CREATE TABLE produto('
  + 'id INTEGER PRIMARY KEY NOT NULL, '
  + 'descricao TEXT, '
  + 'valor REAL)';