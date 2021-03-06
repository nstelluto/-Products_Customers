import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_final/classes/cliente.dart';
import 'package:trabalho_final/repository/repo_cliente.dart';
import 'package:trabalho_final/widgets/loader.dart';
import 'package:flutter/material.dart';

class PageEdit extends StatefulWidget {
  @override
  _PageEditState createState() => _PageEditState();
}

class _PageEditState extends State<PageEdit> {
  var maskCPFCNPJ = MaskTextInputFormatter(    
    mask: "###.###.###-####", 
    filter: { 
      "#": RegExp(r'[0-9]'),
    }
  );
  var maskTel = MaskTextInputFormatter(    
    mask: "+55 (##) #####-####", 
    filter: { 
      "#": RegExp(r'[0-9]'),
    }
  );
  var _ctrId = TextEditingController();
  var _ctrCPF = TextEditingController();
  var _ctrNome = TextEditingController();
  var _ctrEmail = TextEditingController();
  var _ctrTel = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var _ocupado = false;
  RepositoryCliente repositoryCliente;

  Future gravarCliente() async {
    var cliente = Cliente(
      id: int.parse(_ctrId.text),
      nome: _ctrNome.text,
      cpfcnpj: _ctrCPF.text,
      email: _ctrEmail.text,
      telefone: _ctrTel.text,
      sincronizado: 0,
    );

    return await repositoryCliente.updateCliente(cliente);
  }

  @override
  Widget build(BuildContext context) {
    repositoryCliente = Provider.of<RepositoryCliente>(context);
    Cliente cliente = ModalRoute.of(context).settings.arguments;

    _ctrId.value = TextEditingValue(text: cliente.id.toString());
    _ctrNome.value = TextEditingValue(text: cliente.nome);
    _ctrCPF.value = TextEditingValue(text: cliente.cpfcnpj);
    _ctrEmail.value = TextEditingValue(text: cliente.email);
    _ctrTel.value = TextEditingValue(text: cliente.telefone);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.orange[100],
        iconTheme: IconThemeData(
          color: Colors.orange[900],
        ),
        title: Text(
          'Editar cliente',
          style: TextStyle(
            color: Colors.orange[900],
          ),
        ),
      ),
      body: Visibility(
        visible: _ocupado,
        child: Loader('Gravando cliente...'),
        replacement: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _ctrId,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'ID',
                      ),
                    ),
                    TextFormField(
                      controller: _ctrNome,
                      enabled: true,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe o Nome';
                        }
                      },
                    ),
                    TextFormField(
                      controller: _ctrCPF,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        maskCPFCNPJ,
                      ],                      
                      onChanged: (text) {
                        if (text.length > 15) {
                          maskCPFCNPJ.updateMask("##.###.###/####-##");
                        } else {
                          maskCPFCNPJ.updateMask("###.###.###-####");
                        }
                      },
                      enabled: true,
                      decoration: InputDecoration(
                        labelText: 'CPF/CNPJ',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe o CPF ou CNPJ';
                        }
                      },
                    ),                    
                    TextFormField(
                      controller: _ctrEmail,
                      keyboardType: TextInputType.emailAddress,
                      enabled: true,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe o Email';
                        }
                      },
                    ),                    
                    TextFormField(
                      controller: _ctrTel,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        maskTel,
                      ],
                      enabled: true,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Informe o Telefone';
                        }
                      },
                    ),                    
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 20,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              this._ocupado = true;
                            });
                            gravarCliente().then((_) {
                              Navigator.of(context).pop(true);
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            "GRAVAR", 
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 20,                        
                            ),
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
      ),
    );
  }
}
