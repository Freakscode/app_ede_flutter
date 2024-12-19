import 'package:flutter/material.dart';

class PrimeraSubseccion extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fechaController;
  final TextEditingController horaController;
  final TextEditingController nombreEvaluadorController;
  final TextEditingController dependenciaController;
  final TextEditingController idGrupoController;
  final TextEditingController eventoIdController;
  final VoidCallback onGuardar;
  final Future<void> Function(BuildContext) selectDate;
  final Future<void> Function(BuildContext) selectTime;
  final ValueNotifier<ImageProvider?> firmaImageNotifier;
  final Future<void> Function() onSubirFirma;

  const PrimeraSubseccion({
    super.key,
    required this.formKey,
    required this.fechaController,
    required this.horaController,
    required this.nombreEvaluadorController,
    required this.dependenciaController,
    required this.idGrupoController,
    required this.eventoIdController,
    required this.onGuardar,
    required this.selectDate,
    required this.selectTime,
    required this.firmaImageNotifier,
    required this.onSubirFirma,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'IDENTIFICACIÓN DE EVALUACIÓN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002855),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Fecha de inspección
          TextFormField(
            controller: fechaController,
            decoration: InputDecoration(
              labelText: 'Fecha de Inspección',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => selectDate(context),
              ),
            ),
            readOnly: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la fecha de inspección';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Hora
          TextFormField(
            controller: horaController,
            decoration: InputDecoration(
              labelText: 'Hora',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => selectTime(context),
              ),
            ),
            readOnly: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la hora de inspección';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          //Nombre Evaluador
          TextFormField(
            controller: nombreEvaluadorController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Evaluador',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite el nombre del evaluador';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: eventoIdController,
            decoration: const InputDecoration(
              labelText: 'Id Evento',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite el nombre del evaluador';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          // ID Grupo
          TextFormField(
            controller: idGrupoController,
            decoration: const InputDecoration(
              labelText: 'ID Grupo',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el ID de grupo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Dependencia / Entidad
          TextFormField(
            controller: dependenciaController,
            decoration: const InputDecoration(
              labelText: 'Dependencia / Entidad',
              border: OutlineInputBorder(),
            ),
            // Dependencia es opcional según tu lógica, si lo quieres obligatorio, agrega validador
          ),
          const SizedBox(height: 16.0),

          // Botón para subir firma
          GestureDetector(
            onTap: onSubirFirma,
            child: ValueListenableBuilder<ImageProvider?>(
              valueListenable: firmaImageNotifier,
              builder: (context, firmaImage, child) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: firmaImage != null
                      ? Stack(
                          children: [
                            Image(
                              image: firmaImage,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  firmaImageNotifier.value = null;
                                },
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'Tocar para subir firma',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}