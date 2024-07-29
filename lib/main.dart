import 'package:flutter/material.dart';
import 'package:listadecontatos/screen/people_list_screen.dart';
import 'package:listadecontatos/screen/register_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Contatos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegisterScreen(), 
    );
  }
}