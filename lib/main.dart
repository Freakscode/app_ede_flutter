import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/database_helper.dart';
import 'utils/seed_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  await dbHelper.deleteDatabaseFile(); // Eliminar base de datos antes de inicializar

  await dbHelper.database; // Inicializar base de datos
  await seedDatabase(); // Insertar datos de prueba

  // Loguear usuarios
  await dbHelper.logUsuarios();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evaluación de Edificaciones',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}