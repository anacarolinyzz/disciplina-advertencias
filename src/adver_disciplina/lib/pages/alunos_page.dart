import 'package:flutter/material.dart';
import 'package:adver/widget/navigation_drawer.dart';

class AlunosPage extends StatelessWidget{
  const AlunosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: DrawerTest(),
      body: Row(children: [
        Column(children: [Text('Alunos')],)
      ],),
    );
  }
}