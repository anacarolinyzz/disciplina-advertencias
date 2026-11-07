import 'package:flutter/material.dart';
import 'package:adver/widget/navigation_drawer.dart';

class AdvertenciaPage extends StatelessWidget{
  const AdvertenciaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: DrawerTest(),
      body: Row(children: [
        Column(children: [Text('Advertência')],)
      ],),
    );
  }
}