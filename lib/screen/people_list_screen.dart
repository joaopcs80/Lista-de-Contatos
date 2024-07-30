import 'package:flutter/material.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'register_screen.dart';
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
      return people;
    } catch (e) {
      throw Exception('Failed to fetch people: $e');
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
              leading: Icon(FontAwesomeIcons.sortAlphaDown),
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
              leading: Icon(FontAwesomeIcons.phone),
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
              leading: Icon(FontAwesomeIcons.envelope),
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
        title: AutoSizeText(
          'Lista de Contatos',
          style: TextStyle(fontSize: 20),
          maxLines: 1,
        ),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.sort),
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
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                  leadingWidget = Icon(FontAwesomeIcons.user);
                }
              } else {
                leadingWidget = Icon(FontAwesomeIcons.user);
              }

              return ListTile(
                title: AutoSizeText(
                  name,
                  style: TextStyle(fontSize: 18),
                  maxLines: 1,
                ),
                subtitle: AutoSizeText(
                  'Telefone: $phone\nE-mail: $email',
                  style: TextStyle(fontSize: 14),
                  maxLines: 2,
                ),
                leading: leadingWidget,
                trailing: IconButton(
                  icon: Icon(FontAwesomeIcons.trash),
                  onPressed: () => _confirmDelete(context, person['objectId']),
                ),
                onTap: () {
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