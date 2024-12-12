// lib/screens/identificacion_edificacion/identificacion_edificacion_screen.dart

import 'package:flutter/material.dart';

class IdentificacionEdificacionScreen extends StatelessWidget {
  final int evaluacionId;

  const IdentificacionEdificacionScreen({
    super.key,
    required this.evaluacionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identificación de Edificación'),
        backgroundColor: const Color(0xFF002855),
      ),
      body: Center(
        child: Text(
          'ID de Evaluación: $evaluacionId',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}