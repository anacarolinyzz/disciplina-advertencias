import 'package:flutter/material.dart';
import 'package:adver/widget/navigation_drawer.dart';
class UsuarioPage extends StatelessWidget{
  const UsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(),
        drawer: DrawerTest(),
        body: Center(child: Text('Usuário', style: TextStyle(fontSize: 24),),),

      );
  }
}