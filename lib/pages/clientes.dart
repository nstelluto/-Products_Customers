import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trabalho_final/classes/app_routes.dart';
import 'package:trabalho_final/classes/cliente.dart';
import 'package:trabalho_final/pages/token.dart';
import 'package:trabalho_final/repository/repo_cliente.dart';
import 'package:trabalho_final/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class PageClientes extends StatefulWidget {
  @override
  _PageClientesState createState() => _PageClientesState();
}

class _PageClientesState extends State<PageClientes> {
  bool _ocupado = true;
  GetStorage storage = GetStorage();
  List<Cliente> _lista = List<Cliente>();
  RepositoryCliente repositoryCliente = RepositoryCliente();

  Future consultarClientes() async {
    _lista = await repositoryCliente.getClientes();

    setState(() {
      _ocupado = false;
    });
  }

  Future consultarServidor(String token) async {
    Dio dio = Dio();
    Response response = await dio.get(
      URL_BASE + '/clientes',      
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

      repositoryCliente.clearTable();
      
      lista.forEach((item) {
        var cliente = Cliente(
          nome: item['nome'],
          cpfcnpj: item['cpf_cnpj'],
          email: item['email'],
          telefone: item['telefone'],
          sincronizado: 1,
        );


        repositoryCliente.insertCliente(cliente);
      });
    }

    return response.statusCode;
  }

  Future consultarClientesNome(String nome) async {
    _lista.clear();
    _lista = await repositoryCliente.getClientesNome(nome);

    setState(() {});
  }

  Future excluirCliente(Cliente cliente) async {
    await repositoryCliente.deleteCliente(cliente);
  }

  Future sincronizarClientes() async {    
    Dio dio = Dio();

    var token = await storage.read('token');

    if (token == null) {
      return 401;
    }
    
    if (_lista.isNotEmpty) {
      List<Map<String, dynamic>> listaEnvio = List.generate(_lista.length, (index) {
        return _lista.elementAt(index).toMap();
      });
      Response response = await dio.put(
        URL_BASE + '/clientes',      
        options: Options(
          contentType: 'application/json',
          followRedirects: false,
          validateStatus: (status) {
            return status < 500;
          },
          headers: {
            'Authorization' : "Bearer $token",
          }
        ),
        data: json.encode(listaEnvio),
      );

      if (response.statusCode != 200) {
        return false;
      }
    }

    return await consultarServidor(token);
  }

  Widget itemLista(BuildContext context, Cliente cliente, bool ultimo) {
    BoxDecoration _leadingDeco = cliente.sincronizado == 1
      ? BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 3,
            color: Colors.lime[100],
          ),
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 1,
            color: Colors.lightGreen[200],
          ),
        ],
      )
      : BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black26,
        border: Border.all(
          color: Colors.black12,
        )
      );

    return Container(
      decoration: BoxDecoration(
        color: Colors.orange[100],
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
          decoration: _leadingDeco,
        ),
        title: Text(
          cliente.nome,
          style: TextStyle(
            color: Colors.orange[900],
          ),
        ),
        subtitle: Text(
          "${cliente.email}\n${cliente.telefone}",
          style: TextStyle(
            color: Colors.amber[900],
            fontSize: 15,
          ),
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                color: Colors.amber[900],
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.PAGE_EDIT,
                    arguments: cliente,
                  ).then((retorno) {
                    if (retorno) {
                      setState(() {
                        _ocupado = true;
                        consultarClientes();
                      });
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Colors.orange[900],
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Exclusão'),
                      content: Text('Deseja excluir esse cliente?'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            'SIM',                            
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            'NÃO',
                            style: TextStyle(color: Colors.orange[900]),
                          ),
                        ),
                      ],
                    ),
                  ).then((retorno) {
                    if (retorno) {
                      this.excluirCliente(cliente).then((_) {
                        setState(() {
                          this._ocupado = true;
                          consultarClientes();
                        });
                      });
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    consultarClientes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.orange[100],
        iconTheme: IconThemeData(
          color: Colors.orange[900],
        ),
        title: Text(
          'Clientes',
          style: TextStyle(
            color: Colors.orange[900],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.PAGE_ADD).then((retorno) {
                if (retorno) {
                  setState(() {
                    _ocupado = true;
                    consultarClientes();
                  });
                }
              });
            }
          ),
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              setState(() {
                _ocupado = true;
              });
              sincronizarClientes().then((status) {
                if (status == 401) {
                  Navigator.of(context).pushNamed(AppRoutes.PAGE_TOKEN).then((retorno) {
                    if (retorno) {
                      sincronizarClientes().then((_) {
                        consultarClientes();
                      });
                    }
                  });
                }

                consultarClientes();                
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
            child: Loader('Consultando clientes...'),
            replacement: Visibility(
              visible: _lista.isNotEmpty,
              replacement: Center(
                child: Text(
                  'Sem clientes até o momento',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange[900]
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
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Buscar',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.orange[900]
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
                                  color: Colors.orange[200],
                                  width: 2,
                                )
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide(
                                  color: Colors.orange,
                                  width: 2,
                                )
                              ),
                            ),
                            onChanged: (value) {
                              consultarClientesNome(value);
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
                            Cliente cliente = _lista.elementAt(index);
                            
                            return itemLista(context, cliente, cliente == _lista.last);
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
