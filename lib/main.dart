import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import './models/ede_provider.dart';
import 'screens/identificacion_evaluacion/identificacion_evaluacion_screen.dart';
import 'screens/identificacion_edificacion/identificacion_edificacion_screen.dart';
import 'screens/descripcion_edificacion/bloque1.dart';
import 'screens/identificacion_riesgos_externos/identificacion_riesgos_screen.dart';
import 'screens/evaluacion_daños_edificacion/evaluacion_damage_edificacion.dart';
import 'screens/alcance_evaluacion/alcance_evaluacion_screen.dart';
import 'screens/habitabilidad_edificacion/habitabilidad_screen.dart';
import 'screens/acciones_recomendadas/acciones_recomendadas_screen.dart';
import 'screens/resumen_evaluacion_screen.dart';
import 'utils/database_helper.dart';
import 'utils/seed_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dbHelper = DatabaseHelper();
  await dbHelper.deleteDatabaseFile(); // Eliminar base de datos antes de inicializar
  await dbHelper.database; // Inicializar base de datos
  await seedDatabase(); // Insertar datos de prueba
  await dbHelper.logUsuarios(); // Loguear usuarios

  runApp(
    ChangeNotifierProvider(
      create: (_) => EDEProvider(),
      child: const MainApp(),
    ),
  );
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
      home: const LoginScreen(), // Pantalla inicial sin rutas nombradas
      // Definir rutas nombradas para las pantallas posteriores
      routes: {
        '/home': (context) => HomeScreen(
              userName: ModalRoute.of(context)!.settings.arguments != null 
                        ? (ModalRoute.of(context)!.settings.arguments as Map)['userName']
                        : 'Usuario',
              userId: ModalRoute.of(context)!.settings.arguments != null 
                        ? (ModalRoute.of(context)!.settings.arguments as Map)['userId']
                        : 0,
            ),
        '/identificacion_evaluacion': (context) => IdentificacionEvaluacionScreen(
              userId: (ModalRoute.of(context)!.settings.arguments as Map)['userId'],
              evaluacionId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionId'],
            ),
        '/identificacion_edificacion': (context) => IdentificacionEdificacionScreen(
              userId: (ModalRoute.of(context)!.settings.arguments as Map)['userId'],
              evaluacionId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionId'],
            ),
        '/descripcion_edificacion': (context) => Bloque1Screen(
              userId: (ModalRoute.of(context)!.settings.arguments as Map)['userId'],
              evaluacionId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionId'],
              evaluacionEdificioId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionEdificioId'],
            ),
        '/identificacion_riesgos_externos': (context) => IdentificacionRiesgosExternosScreen(
              userId: (ModalRoute.of(context)!.settings.arguments as Map)['userId'],
              evaluacionId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionId'],
              evaluacionEdificioId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionEdificioId'],
            ),
        '/evaluacion_danos': (context) => EvaluacionDamagesEdificacionScreen(
              userId: (ModalRoute.of(context)!.settings.arguments as Map)['userId'],
              evaluacionId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionId'],
              evaluacionEdificioId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionEdificioId'],
            ),
        '/alcance_evaluacion': (context) => AlcanceEvaluacionScreen(
              userId: (ModalRoute.of(context)!.settings.arguments as Map)['userId'],
              evaluacionId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionId'],
              evaluacionEdificioId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionEdificioId'],
            ),
        '/habitabilidad': (context) => HabitabilidadScreen(
              userId: (ModalRoute.of(context)!.settings.arguments as Map)['userId'],
              evaluacionId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionId'],
              evaluacionEdificioId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionEdificioId'],
              severidadDanio: (ModalRoute.of(context)!.settings.arguments as Map)['severidadDanio'],
              porcentajeAfectacion: (ModalRoute.of(context)!.settings.arguments as Map)['porcentajeAfectacion'],
            ),
        '/acciones_recomendadas': (context) => RecomendacionesMedidasScreen(
              userId: (ModalRoute.of(context)!.settings.arguments as Map)['userId'],
              evaluacionId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionId'],
              evaluacionEdificioId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionEdificioId'],
            ),
        '/resumen_evaluacion': (context) => ResumenEvaluacionScreen(
              userId: (ModalRoute.of(context)!.settings.arguments as Map)['userId'],
              evaluacionId: (ModalRoute.of(context)!.settings.arguments as Map)['evaluacionId'],
            ),
      },
    );
  }
}
