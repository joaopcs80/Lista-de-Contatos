import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../service/api_service.dart';
import '../screen/people_list_screen.dart';

class RegisterScreen extends StatefulWidget {
  final Map<String, dynamic>? contact;

  RegisterScreen({this.contact});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!['name'];
      _imageFile = widget.contact!['profilePicPath'] != null
          ? File(widget.contact!['profilePicPath'])
          : null;
    }
  }

  Future<void> _pickAndCropImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      );

      setState(() {
        _imageFile = File(croppedFile!.path);
      });
    }
  }

  Future<void> _saveOrUpdatePerson() async {
    final apiService = ApiService();
    try {
      if (widget.contact == null) {
        await apiService.createPerson(
          _nameController.text,
          _imageFile?.path ?? '',
        );
      } else {
        await apiService.updatePerson(
          widget.contact!['objectId'], 
          _nameController.text,
          _imageFile?.path ?? '',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contato ${widget.contact == null ? 'registrado' : 'atualizado'} com sucesso!')),       
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PeopleListScreen()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contact == null ? 'Register Person' : 'Edit Person')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            _imageFile == null
                ? const Text('Nenhuma imagem selecionada.')
                : Image.file(_imageFile!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickAndCropImage,
              child: const Text('Selecionar Imagem'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveOrUpdatePerson,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}