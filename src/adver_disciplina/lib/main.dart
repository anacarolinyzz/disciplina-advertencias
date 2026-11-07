import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/alunos_page.dart';
import 'pages/advertencias_page.dart';
import 'pages/relatorios_page.dart';
import 'pages/usuario_page.dart';
import 'pages/configuracao_page.dart';
import 'pages/login_page.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Adver - Sistema de Gestão',
          
          // Configuração dos Temas Claro e Escuro
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFE5E5E5),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 1,
            ),
          ),

          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginPage(),
            '/home': (context) => const HomePage(),
            '/alunos': (context) => const AlunosPage(),
            '/advertencia': (context) => const AdvertenciaPage(),
            '/relatorios': (context) => const RelatorioPage(),
            '/usuario': (context) => const UsuarioPage(),
            '/configuracao': (context) => const ConfiguracaoPage(),
          },
        );
      },
    );
  }
}
