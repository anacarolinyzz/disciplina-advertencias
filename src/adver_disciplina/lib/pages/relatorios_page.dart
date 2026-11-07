import 'package:flutter/material.dart';
import 'package:adver/widget/navigation_drawer.dart';
import 'package:adver/widget/appbar_principal.dart';
class RelatorioPage extends StatelessWidget{
  const RelatorioPage({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppbarPrincipal(),
        drawer: DrawerTest(),
        body: Center(child: Text('Relatórios', style: TextStyle(fontSize: 24),),),

      );
  }
}