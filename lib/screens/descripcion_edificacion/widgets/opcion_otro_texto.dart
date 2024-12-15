import 'package:flutter/material.dart';

class OpcionOtroTexto extends StatelessWidget {
  final bool visible;
  final TextEditingController controller;

  const OpcionOtroTexto({
    Key? key,
    required this.visible,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return visible
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Especificar',
                border: OutlineInputBorder(),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}