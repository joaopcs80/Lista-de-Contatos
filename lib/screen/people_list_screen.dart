import 'package:flutter/material.dart';
import 'package:listadecontatos/screen/register_screen.dart';
import '../service/api_service.dart';

class PeopleListScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchPeople() async {
    final apiService = ApiService();
    return await apiService.fetchPeople();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Contatos')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPeople(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Contato não encontrado.'));
          }

          final people = snapshot.data!;
          return ListView.builder(
            itemCount: people.length,
            itemBuilder: (context, index) {
              final person = people[index];
              final name = person['name'] ?? 'No name';
              final profilePicPath = person['profilePicPath'] ?? '';
              return ListTile(
                title: Text(name),
                leading: profilePicPath.isNotEmpty
                    ? Image.network(profilePicPath)
                    : Icon(Icons.person),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterScreen(contact: person),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Registrar Contato',
      ),
    );
  }
}