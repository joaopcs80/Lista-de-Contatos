import 'package:flutter/material.dart';
import 'package:listadecontatos/screen/people_list_screen.dart'; // Importação correta

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'People App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PeopleListScreen(), // Tela inicial correta
    );
  }
}