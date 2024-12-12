import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/usuario.dart';
import '../utils/database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Función para hashear la contraseña
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Login
  Future<Usuario?> login(String cedula, String password) async {
    final db = await _dbHelper.database;

    // Hashear la contraseña ingresada
    String hashedPassword = hashPassword(password);

    // Consultar al usuario con la cédula y contraseña hasheada
    List<Map<String, dynamic>> results = await db.query(
      'Usuarios',
      where: 'cedula = ? AND pwd = ?',
      whereArgs: [cedula, hashedPassword],
    );

    if (results.isNotEmpty) {
      Map<String, dynamic> userMap = results.first;
      return Usuario.fromMap(userMap);
    } else {
      return null;
    }
  }

  // Registrar usuario
  Future<bool> register(Usuario usuario) async {
    try {
      final hashedPassword = hashPassword(usuario.pwd);
      final userMap = usuario.toMap();
      userMap['pwd'] = hashedPassword;
      await _dbHelper.insertarUsuario(userMap);
      return true;
    } catch (e) {
      print('Error registrando usuario: $e');
      return false;
    }
  }
}