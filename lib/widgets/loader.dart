import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final String texto;

  Loader(this.texto);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CircularProgressIndicator(),
            Text(texto),
          ]
        ),
      ),
    );
  }
}