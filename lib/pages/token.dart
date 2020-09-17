import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trabalho_final/classes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_final/widgets/loader.dart';

const URL_BASE = 'http://localhost:8080/trabalho_final/index.php';

class PageToken extends StatefulWidget {
  @override
  _PageTokenState createState() => _PageTokenState();
}

class _PageTokenState extends State<PageToken> {
  GetStorage storage = GetStorage();
  bool _ocupado = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _ctrEmail = TextEditingController();

  Future gravarToken(String token) async {
    return await storage.write('token', token);
  }

  Future solicitarToken() async {
    Dio dio = Dio();
    Response response = await dio.post(
      URL_BASE + '/token',      
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
        followRedirects: false,
        validateStatus: (status) {
          return status < 500;
        }
      ),
      data: {
        'email' : this._ctrEmail.text,
      }
    );

    if (response.statusCode == 200) {
      await gravarToken(response.data['mensagem']['token']);
    }

    setState(() {
      this._ocupado = false;
    });

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Visibility(
          visible: _ocupado,
          child: Loader('Validando email...'),
          replacement: Container(        
            constraints: BoxConstraints(
              maxHeight: 200,
              maxWidth: MediaQuery.of(context).size.width * 0.75
            ),
            alignment: Alignment.center,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextFormField(
                    controller: _ctrEmail,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Informe o email';
                      }
                    },
                    textAlign: TextAlign.center,
                    style: TextStyle(                    
                      color: Colors.indigo[900],
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.indigo[100],
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(
                          color: Colors.teal[100],
                          width: 2,
                        )
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(
                          color: Colors.red[200],
                          width: 2,
                        )
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(
                          color: Colors.red[100],
                          width: 2,
                        )
                      ) 
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if(_formKey.currentState.validate()) {
                        setState(() {
                          _ocupado = true;
                        });
                        solicitarToken().then((response) {
                          if (response.statusCode == 200) {
                            Navigator.of(context).pop(true);
                          } else {
                            print(response);
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Erro'),
                                content: Text('Email inválido!'),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        "Enviar", 
                        style: TextStyle(
                          color: Colors.teal[900],
                          fontSize: 20,                        
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )  
          ),
        ),
      ),
    );
  } 
}