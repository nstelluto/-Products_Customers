import 'package:trabalho_final/classes/produto.dart';
import 'package:trabalho_final/utils/ddl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RepositoryProduto {
  Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), DATABASE_NAME),
      onCreate: (db, version) {
        db.execute(CREATE_TABLE_PRODUTO);
        db.execute(CREATE_TABLE_CLIENTE);
      },
      version: 1,
    );
  }

  Future<String> countRegistries() async {
    try {
      final Database db = await _getDatabase();
      final data = await db.rawQuery('SELECT count(*) as total FROM produto');

      return data[0]['total'].toString();
    } catch (e) {
      print(e);

      return '-1';
    }
  }

  Future<List<Produto>> getProdutos() async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps =
          await db.query('produto', orderBy: 'id DESC');

      return List.generate(maps.length, (index) {
        return Produto.fromMap(maps[index]);
      });
    } catch (e) {
      print(e);

      return List<Produto>();
    }
  }

  Future<List<Produto>> getProdutosNome(String nome) async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        'produto',
        where: 'descricao LIKE ?',
        whereArgs: ['%' + nome + '%'],
        orderBy: 'id DESC'
      );

      return List.generate(maps.length, (index) {
        return Produto.fromMap(maps[index]);
      });
    } catch (e) {
      print(e);

      return List<Produto>();
    }
  }

  Future insertProduto(Produto produto) async {
    try {
      final Database db = await _getDatabase();
      await db.insert('produto', produto.toMap());

      return true;
    } catch (e) {
      print(e);
    }
  }

  Future updateProduto(Produto produto) async {
    try {
      final Database db = await _getDatabase();
      await db.update(
        'produto',
        produto.toMap(), 
        where: 'id = ?',
        whereArgs: [produto.id]
      );

      return true;
    } catch (e) {
      print(e);
    }
  }

  Future deleteProduto(Produto produto) async {
    try {
      final Database db = await _getDatabase();
      await db.delete('produto', where: 'id = ?', whereArgs: [produto.id]);
    } catch (e) {
      print(e);
    }
  }

  Future clearTable() async {
    try {
      final Database db = await _getDatabase();
      await db.delete('produto');
    } catch (e) {
      print(e);
    }
  }
}
