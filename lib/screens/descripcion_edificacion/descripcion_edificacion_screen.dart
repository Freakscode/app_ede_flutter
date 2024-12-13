import 'package:flutter/material.dart';

class DescripcionEdificacionScreen extends StatelessWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;

  const DescripcionEdificacionScreen({
    super.key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descripción de la Edificación'),
        backgroundColor: const Color(0xFF002855),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Datos Guardados Exitosamente!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Evaluación ID: $evaluacionId',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Evaluación Edificio ID: $evaluacionEdificioId',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}