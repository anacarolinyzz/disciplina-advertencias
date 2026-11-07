import 'package:flutter/material.dart';
import '../main.dart'; // Importa o themeNotifier global

class AppbarPrincipal extends StatelessWidget implements PreferredSizeWidget {
  const AppbarPrincipal({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 35,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, size: 32),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adver',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Sistema de Gestão',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
      // Propriedade actions coloca os elementos no canto direito do AppBar
      actions: [
        IconButton(
          tooltip: isDark ? 'Modo Claro' : 'Modo Escuro',
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? Colors.amber : Colors.grey[800],
          ),
          onPressed: () {
            // Alterna entre ThemeMode.light e ThemeMode.dark
            themeNotifier.value =
                themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}