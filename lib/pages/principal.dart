import 'package:trabalho_final/classes/app_routes.dart';
import 'package:trabalho_final/classes/cliente.dart';
import 'package:trabalho_final/repository/repo_cliente.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_final/repository/repo_produto.dart';

class PagePrincipal extends StatefulWidget {
  @override
  _PagePrincipalState createState() => _PagePrincipalState();
}

class _PagePrincipalState extends State<PagePrincipal> {
  var _totalClientes = '0';
  var _totalProdutos = '0';
  RepositoryCliente repositoryCliente;
  RepositoryProduto repositoryProduto;

  @override
  Widget build(BuildContext context) {
    repositoryCliente = Provider.of<RepositoryCliente>(context);
    repositoryProduto = Provider.of<RepositoryProduto>(context);

    repositoryCliente.countRegistries().then((value) {
      setState(() {
        _totalClientes = value;
      });
    });
    
    repositoryProduto.countRegistries().then((value) {
      setState(() {
        _totalProdutos = value;
      });
    });

    return Scaffold(
      body: Center(
        child: Container(        
          constraints: BoxConstraints(
            maxHeight: 200,
            maxWidth: MediaQuery.of(context).size.width * 0.75
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.PAGE_PRODUTOS);
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[100],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    "Produtos ($_totalProdutos)", 
                    style: TextStyle(
                      color: Colors.lightBlue[900],
                      fontSize: 20,                        
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.PAGE_CLIENTES);
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    "Clientes ($_totalClientes)", 
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 20,                        
                    ),
                  ),
                ),
              ),
            ],
          )  
        ),
      ),
    );
  } 
}