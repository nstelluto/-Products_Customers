import 'package:get_storage/get_storage.dart';
import 'package:trabalho_final/classes/app_routes.dart';
import 'package:trabalho_final/pages/add.dart';
import 'package:trabalho_final/pages/clientes.dart';
import 'package:trabalho_final/pages/edit.dart';
import 'package:trabalho_final/pages/principal.dart';
import 'package:trabalho_final/pages/produtos.dart';
import 'package:trabalho_final/pages/token.dart';
import 'package:trabalho_final/repository/repo_cliente.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_final/repository/repo_produto.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RepositoryCliente>(
          create: (_) => RepositoryCliente(),
        ),
        Provider<RepositoryProduto>(
          create: (_) => RepositoryProduto(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        routes: {
          AppRoutes.PAGE_PRINCIPAL: (_) => PagePrincipal(),
          AppRoutes.PAGE_TOKEN: (_) => PageToken(),
          AppRoutes.PAGE_CLIENTES: (_) => PageClientes(),
          AppRoutes.PAGE_PRODUTOS: (_) => PageProdutos(),
          AppRoutes.PAGE_ADD: (_) => PageAdd(),
          AppRoutes.PAGE_EDIT: (_) => PageEdit(),
        },
      ),
    );
  }
}
