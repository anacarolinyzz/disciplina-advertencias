import 'package:flutter/material.dart';
import 'package:adver/widget/navigation_drawer.dart';
class ConfiguracaoPage extends StatelessWidget{
  const ConfiguracaoPage({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(),
        drawer: DrawerTest(),
        body: Center(child: Text('Configuração', style: TextStyle(fontSize: 24),),),

      );
  }
}