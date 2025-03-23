import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditUserScreen extends StatefulWidget {
  final int userId;
  final String accessToken;

  const EditUserScreen({
    Key? key,
    required this.userId,
    required this.accessToken,
  }) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _avatar;  // Imagen local
  String? _avatarName;  // Nombre del archivo
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🚀 Cargar datos del usuario
  Future<void> _loadUserData() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/admin/${widget.userId}/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);

        setState(() {
          _usernameController.text = user['username'];
          _emailController.text = user['email'];
          _descriptionController.text = user['description'] ?? '';

          if (user['avatar'] != null && user['avatar'].isNotEmpty) {
            _avatarName = user['avatar'];
            _loadLocalImage(_avatarName!);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuario: $e')),
      );
    }
  }

  /// 📌 Cargar imagen local si existe
  Future<void> _loadLocalImage(String avatarName) async {
    final directory = await getApplicationDocumentsDirectory();
    final avatarFile = File('${directory.path}/images/$avatarName');

    if (avatarFile.existsSync()) {
      setState(() => _avatar = avatarFile);
    }
  }

  /// 📷 Método para seleccionar nueva imagen
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String newPath = '${directory.path}/images/${image.name}';

      final File newImage = await File(image.path).copy(newPath);

      setState(() {
        _avatar = newImage;
        _avatarName = image.name;  // Actualiza el nombre
      });
    }
  }

  /// 🔥 Actualizar usuario
  Future<void> _updateUser() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/admin/${widget.userId}/');

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> body = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'description': _descriptionController.text,
      };

      // Agrega la imagen si hay una
      if (_avatar != null && _avatarName != null) {
        body['avatar'] = _avatarName;
      }

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario actualizado correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar usuario')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Usuario')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _avatar != null
                    ? FileImage(_avatar!)
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
                child: _avatar == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Nombre de usuario'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateUser,
                    child: Text('Actualizar'),
                  ),
          ],
        ),
      ),
    );
  }
}