import 'package:flutter/material.dart';
import 'dart:io'; 
import 'package:listadecontatos/screen/register_screen.dart';
import '../service/api_service.dart';

class PeopleListScreen extends StatefulWidget {
  @override
  _PeopleListScreenState createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends State<PeopleListScreen> {
  late Future<List<Map<String, dynamic>>> _peopleFuture;
  String _sortOrder = 'name'; 

  @override
  void initState() {
    super.initState();
    _peopleFuture = _fetchPeople();
  }

  Future<List<Map<String, dynamic>>> _fetchPeople() async {
    final apiService = ApiService();
    try {
      final people = await apiService.fetchPeople();
      people.sort((a, b) {
        if (_sortOrder == 'name') {
          return (a['name'] ?? '').compareTo(b['name'] ?? '');
        } else if (_sortOrder == 'phone') {
          return (a['phone'] ?? '').compareTo(b['phone'] ?? '');
        } else if (_sortOrder == 'email') {
          return (a['email'] ?? '').compareTo(b['email'] ?? '');
        }
        return 0;
      });
      print('Dados recebidos: $people');
      return people;
    } catch (e) {
      print('Erro ao buscar pessoas: $e');
      throw e;
    }
  }

  Future<void> _refreshPeople() async {
    setState(() {
      _peopleFuture = _fetchPeople();
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.sort_by_alpha),
              title: Text('Ordenar por Nome'),
              onTap: () {
                setState(() {
                  _sortOrder = 'name';
                  _refreshPeople();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Ordenar por Telefone'),
              onTap: () {
                setState(() {
                  _sortOrder = 'phone';
                  _refreshPeople();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Ordenar por E-mail'),
              onTap: () {
                setState(() {
                  _sortOrder = 'email';
                  _refreshPeople();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePerson(String objectId) async {
    final apiService = ApiService();
    try {
      await apiService.deletePerson(objectId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contato deletado com sucesso!')),
      );
      _refreshPeople();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar contato: $e')),
      );
    }
  }

  void _confirmDelete(BuildContext context, String objectId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja deletar este contato?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Deletar'),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePerson(objectId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Contatos'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _peopleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Erro no FutureBuilder: ${snapshot.error}');
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('Nenhum contato encontrado.');
            return Center(child: Text('Nenhum contato encontrado.'));
          }

          final people = snapshot.data!;
          return ListView.builder(
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              final name = person['name'] ?? 'Sem nome';
              final profilePicPath = person['profilePicPath'] ?? '';
              final phone = person['phone'] ?? 'Sem telefone';
              final email = person['email'] ?? 'Sem e-mail';

              Widget leadingWidget;
              if (profilePicPath.isNotEmpty) {
                final file = File(profilePicPath);
                if (file.existsSync()) {
                  leadingWidget = Image.file(
                    file,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  );
                } else {
                  leadingWidget = Icon(Icons.person);
                }
              } else {
                leadingWidget = Icon(Icons.person);
              }

              return ListTile(
                title: Text(name),
                subtitle: Text('Telefone: $phone\nE-mail: $email'),
                leading: leadingWidget,
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _confirmDelete(context, person['objectId']),
                ),
                onTap: () {
                  print('Item clicado: $name');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterScreen(contact: person),
                    ),
                  ).then((_) {
                    _refreshPeople();
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('Botão flutuante clicado');
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
          if (result == true) {
            _refreshPeople();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Registrar Contato',
      ),
    );
  }
}