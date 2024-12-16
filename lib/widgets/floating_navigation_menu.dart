import 'package:flutter/material.dart';

class FloatingSectionsMenu extends StatelessWidget {
  final int currentSection;
  final Function(int) onSectionSelected;

  const FloatingSectionsMenu({
    super.key, 
    required this.currentSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.menu),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Secciones del formulario'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    _buildSectionTile(context, 1, 'Identificación de la Evaluación'),
                    _buildSectionTile(context, 2, 'Identificación de la Edificación'),
                    _buildSectionTile(context, 3, 'Descripción de la Edificación'),
                    _buildSectionTile(context, 4, 'Riesgos Externos'),
                    _buildSectionTile(context, 5, 'Evaluación de Daños'),
                    _buildSectionTile(context, 6, 'Evaluación Global'),
                    _buildSectionTile(context, 7, 'Habitabilidad'),
                    _buildSectionTile(context, 8, 'Recomendaciones'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTile(BuildContext context, int section, String title) {
    return ListTile(
      leading: Icon(
        currentSection == section ? Icons.check_circle : Icons.circle_outlined,
        color: currentSection == section ? Colors.green : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: currentSection == section ? FontWeight.bold : FontWeight.normal,
          color: currentSection == section ? Theme.of(context).primaryColor : Colors.black,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onSectionSelected(section);
      },
    );
  }
}