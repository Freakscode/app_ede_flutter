import '../../screens/descripcion_edificacion/usos_predominantes.dart';
import 'package:flutter/material.dart';
import 'caracteristicas_generales.dart';
import '../../widgets/floating_navigation_menu.dart'; // Importar el menú flotante

class Bloque1Screen extends StatefulWidget {
  final int evaluacionId;
  final int evaluacionEdificioId;
  final int userId;

  const Bloque1Screen({
    super.key,
    required this.evaluacionId,
    required this.evaluacionEdificioId,
    required this.userId,
  });

  @override
  State<Bloque1Screen> createState() => _Bloque1ScreenState();
}

class _Bloque1ScreenState extends State<Bloque1Screen> {
  static const Color primaryColor = Color(0xFF002342);
  static const Color whiteColor = Color(0xFFFFFFFF);
  
  int _currentIndex = 0;
  late List<Widget> _screens;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _screens = [
      CaracteristicasGeneralesScreen(
        evaluacionId: widget.evaluacionId,
        evaluacionEdificioId: widget.evaluacionEdificioId,
      ),
      UsosPredominantesScreen(
        evaluacionId: widget.evaluacionId,
        evaluacionEdificioId: widget.evaluacionEdificioId,
        userId: widget.userId,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSectionSelected(int section) {
    setState(() {
      _currentIndex = section - 1;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 0,
        title: const Text(
          'Descripción de la Edificación',
          style: TextStyle(color: whiteColor),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / 2,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(whiteColor),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(1, '3.1 Características'),
                _buildStepConnector(_currentIndex >= 0),
                _buildStepIndicator(2, '3.2 Usos'),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentIndex > 0)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteColor,
                    foregroundColor: primaryColor,
                  ),
                  onPressed: () => _onSectionSelected(_currentIndex),
                  child: const Text('Anterior'),
                )
              else
                const SizedBox.shrink(),
              if (_currentIndex < _screens.length - 1)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteColor,
                    foregroundColor: primaryColor,
                  ),
                  onPressed: () => _onSectionSelected(_currentIndex + 2),
                  child: const Text('Siguiente'),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingSectionsMenu(
        currentSection: _currentIndex + 1,
        onSectionSelected: _onSectionSelected,
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentIndex >= step - 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? whiteColor : Colors.white24,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? primaryColor : whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: whiteColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive ? whiteColor : Colors.white24,
    );
  }
}