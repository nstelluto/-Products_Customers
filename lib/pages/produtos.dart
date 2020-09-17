import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trabalho_final/classes/app_routes.dart';
import 'package:trabalho_final/classes/produto.dart';
import 'package:trabalho_final/pages/token.dart';
import 'package:trabalho_final/repository/repo_produto.dart';
import 'package:trabalho_final/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class PageProdutos extends StatefulWidget {
  @override
  _PageProdutosState createState() => _PageProdutosState();
}

class _PageProdutosState extends State<PageProdutos> {
  bool _ocupado = true;
  GetStorage storage = GetStorage();
  List<Produto> _lista = List<Produto>();
  RepositoryProduto repositoryProduto = RepositoryProduto();

  Future sincronizarProdutos() async {
    Dio dio = Dio();

    var token = await storage.read('token');

    if (token == null) {
      return 401;
    }
    
    Response response = await dio.get(
      URL_BASE + '/produtos',      
      options: Options(
        followRedirects: false,
        validateStatus: (status) {
          return status < 500;
        },
        headers: {
          'Authorization' : "Bearer $token",
        }
      ),
    );

    if (response.statusCode == 200) {
      var lista = response.data[1];

      repositoryProduto.clearTable();
      
      lista.forEach((item) {
        var produto = Produto(
          descricao: item['descricao'],
          valor: double.parse(item['valor']),
        );

        repositoryProduto.insertProduto(produto);
      });
    }

    return response.statusCode;
  }

  Future consultarProdutos() async {
    _lista = await repositoryProduto.getProdutos();

    setState(() {
      _ocupado = false;
    });
  }

  Future consultarProdutosNome(String nome) async {
    _lista.clear();
    _lista = await repositoryProduto.getProdutosNome(nome);

    setState(() {});
  }

  Widget itemLista(BuildContext context, Produto produto, bool ultimo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: ultimo
          ? BorderRadius.vertical(bottom:Radius.circular(15))
          : null,
      ),
      child: ListTile(        
        isThreeLine: true,
        leading: Container(
          margin: EdgeInsets.all(10),
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.lightBlue[50],
          ),
        ),
        title: Text(
          produto.descricao,
          style: TextStyle(
            color: Colors.lightBlue[900],
          ),
        ),
        subtitle: Text(
          "#${produto.id}\nR\$ ${produto.valor}",
          style: TextStyle(
            color: Colors.cyan[900],
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    consultarProdutos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.lightBlue[100],
        iconTheme: IconThemeData(
          color: Colors.lightBlue[900],
        ),
        title: Text(
          'Produtos',
          style: TextStyle(
            color: Colors.lightBlue[900],
          ),
        ),
        actions: <Widget>[
          // Remover token (somente para testes)
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              storage.remove('token');
              repositoryProduto.clearTable();
              consultarProdutos();
            }
          ),
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              setState(() {
                _ocupado = true;
              });
              sincronizarProdutos().then((status) {
                if (status == 401) {
                  Navigator.of(context).pushNamed(AppRoutes.PAGE_TOKEN).then((retorno) {
                    if (retorno) {
                      sincronizarProdutos().then((_) {
                        consultarProdutos();
                      });
                    }
                  });
                }

                consultarProdutos();                
              });
            }
          ),          
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 80,
          child: Visibility(
            visible: _ocupado,
            child: Loader('Consultando produtos...'),
            replacement: Visibility(
              visible: _lista.isNotEmpty,
              replacement: Center(
                child: Text(
                  'Sincronize para consultar produtos!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.lightBlue[900]
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Buscar',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.lightBlue[900]
                          ),
                        ),
                        Container(
                          width: 200,
                          child: TextField(                        
                            decoration: InputDecoration(            
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide(
                                  color: Colors.lightBlue[200],
                                  width: 2,
                                )
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide(
                                  color: Colors.lightBlue,
                                  width: 2,
                                )
                              ),
                            ),
                            onChanged: (value) {
                              consultarProdutosNome(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 0,
                        right: 20,
                        bottom: 20,
                        left: 20,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _lista.length,
                          itemBuilder: (context, index) {
                            Produto produto = _lista.elementAt(index);
                            
                            return itemLista(context, produto, produto == _lista.last);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}