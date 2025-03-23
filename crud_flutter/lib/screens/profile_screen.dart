import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String accessToken;
  ProfileScreen({required this.accessToken});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;             // Imagen local
  String? _imageName;       // Nueva imagen seleccionada
  String? _currentAvatar;   // Nombre de la imagen en el servidor
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// ✅ **Descargar imagen del servidor o cargar la local**
  Future<void> _fetchUserData() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/user/profile/');

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _usernameController.text = data['username'];
          _emailController.text = data['email'];
          _descriptionController.text = data['description'];
          _currentAvatar = data['avatar'];
        });

        // Verificar si ya tienes la imagen localmente
        final localImagePath = await _getLocalImagePath(_currentAvatar!);
        if (File(localImagePath).existsSync()) {
          // Mostrar la imagen local si ya existe
          setState(() {
            _image = File(localImagePath);
          });
        } else {
          // Descargar y guardar la imagen si no existe localmente
          await _downloadAndSaveImage(_currentAvatar!);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los datos')),
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

  /// 🚀 **Descargar la imagen desde el servidor**
  Future<void> _downloadAndSaveImage(String imageName) async {
    final imageUrl = 'http://10.0.2.2:8000/media/$imageName';
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imagesDir = Directory('${appDir.path}/images');

      if (!imagesDir.existsSync()) {
        await imagesDir.create(recursive: true);
      }

      final String filePath = '${imagesDir.path}/$imageName';
      final File localFile = File(filePath);

      await localFile.writeAsBytes(response.bodyBytes);

      setState(() {
        _image = localFile;  // Mostrar la imagen descargada
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagen guardada localmente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar la imagen')),
      );
    }
  }

  /// 🔥 **Obtener la ruta local de la imagen**
  Future<String> _getLocalImagePath(String imageName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/images/$imageName';
  }

  /// 📌 **Seleccionar una nueva imagen**
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imagesDir = Directory('${appDir.path}/images');

      if (!imagesDir.existsSync()) {
        await imagesDir.create(recursive: true);
      }

      final String fileName = 'user_avatar_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${imagesDir.path}/$fileName';

      await imageFile.copy(filePath);

      setState(() {
        _image = File(filePath);
        _imageName = fileName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagen seleccionada: $_imageName')),
      );
    }
  }

  /// 🚀 **Actualizar los datos del perfil**
  Future<void> _updateUserData() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/user/profile/');

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'email': _emailController.text,
          'description': _descriptionController.text,
          'avatar': _imageName ?? _currentAvatar,  // Imagen nueva o actual
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado exitosamente')),
        );
        _fetchUserData();  // Recargar los datos
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el perfil')),
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
      appBar: AppBar(title: Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null
                          ? FileImage(_image!)  // Mostrar local
                          : null,
                      child: _image == null
                          ? Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Nombre de Usuario'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Correo Electrónico'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Descripción'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUserData,
                    child: Text('Actualizar Perfil'),
                  ),
                ],
              ),
      ),
    );
  }
}