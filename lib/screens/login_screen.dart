import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _cedulaController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    // Agregar logs de debugging
    print('Iniciando proceso de login');
    print('Cédula ingresada: ${_cedulaController.text}');
    print('Contraseña ingresada: ${_passwordController.text}');

    setState(() => _isLoading = true);

    try {
      // Log antes de autenticar
      print('Intentando autenticar usuario...');

      final usuario = await _authService.login(
        _cedulaController.text,
        _passwordController.text,
      );

      // Log resultado de autenticación
      print('Resultado autenticación: ${usuario != null ? 'exitoso' : 'fallido'}');

      if (usuario != null) {
        if (!mounted) return;

        // Log antes de navegar
        print('Navegando a HomeScreen...');

        // Navegar a HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userName: usuario.nombre,
              userId: usuario.id, // Asegúrate de que 'usuario' tiene el campo 'id'
            ),
          ),
        );
      } else {
        if (!mounted) return;
        // Log error de credenciales
        print('Error: Credenciales inválidas');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales inválidas')),
        );
      }
    } catch (e) {
      // Log error general
      print('Error durante login: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Encabezado superior con bordes redondeados inferiores
                    Container(
                      padding: const EdgeInsets.only(top: 60, bottom: 20),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF002855), // Azul oscuro
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            "DAGRD - APP EDE",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Evaluación de Daños en Edificaciones",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Logo central responsivo
                    Image.asset(
                      'assets/images/medellin_logo.png', // Reemplaza con tu ruta de imagen
                      height: MediaQuery.of(context).size.height * 0.3, // 30% de la altura de la pantalla
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Aplicación para la Evaluación\n de Daños en Edificaciones",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF002855), // Azul oscuro
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Campos de texto
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          TextField(
                            controller: _cedulaController,
                            decoration: InputDecoration(
                              hintText: "Cédula",
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Contraseña",
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                print("Olvidaste la contraseña presionado");
                              },
                              child: const Text(
                                "¿Olvidaste la contraseña?",
                                style: TextStyle(
                                  color: Color(0xFF002855),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Botón Ingresar
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFAD502), // Amarillo
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isLoading 
                                ? const CircularProgressIndicator()
                                : const Text(
                                  "INGRESAR",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Pie de página con bordes redondeados superiores
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF002855),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            'assets/images/logos.png', // Reemplaza con la imagen izquierda
                            height: 80,
                          ),
                          // Puedes agregar más elementos aquí si lo deseas
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}