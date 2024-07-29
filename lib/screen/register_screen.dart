import 'package:flutter/material.dart';
import 'dart:io'; // Import necessário para trabalhar com arquivos
import 'package:image_picker/image_picker.dart'; // Para selecionar imagens
import '../service/api_service.dart';

class RegisterScreen extends StatefulWidget {
  final Map<String, dynamic>? contact;

  RegisterScreen({this.contact});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact?['name'] ?? '';
      _phoneController.text = widget.contact?['phone'] ?? '';
      _emailController.text = widget.contact?['email'] ?? '';
      _loadImage(widget.contact?['profilePicPath']);
    }
  }

  Future<void> _loadImage(String? path) async {
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        setState(() {
          _imageFile = file;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveOrUpdatePerson() async {
    final apiService = ApiService();
    try {
      if (widget.contact == null) {
        await apiService.createPerson(
          _nameController.text,
          _phoneController.text,
          _emailController.text,
          _imageFile?.path ?? '',
        );
      } else {
        await apiService.updatePerson(
          widget.contact!['objectId'],
          _nameController.text,
          _phoneController.text,
          _emailController.text,
          _imageFile?.path ?? '',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contato ${widget.contact == null ? 'registrado' : 'atualizado'} com sucesso!')),
      );
      Navigator.pop(context, true); // Retornar verdadeiro indicando que houve uma atualização
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contact == null ? 'Registrar Contato' : 'Editar Contato')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      width: 100, // Ajuste o tamanho conforme necessário
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.person, size: 100),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Selecionar Imagem'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveOrUpdatePerson,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}