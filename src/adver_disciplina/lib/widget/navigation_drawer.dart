import 'package:flutter/material.dart';




class DrawerTest extends StatelessWidget {
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(decoration: BoxDecoration(color: Color.fromARGB(255, 49, 49, 49)), child: 
          Text('Menu', style: TextStyle(color: Color.fromARGB(255, 253, 253, 253)),)),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Início'),
            onTap: (){
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.person_search),
            title: const Text('alunos'),
            onTap: (){
              Navigator.pop(context);
              Navigator.pushNamed(context, '/alunos');
            },
          ),
          ListTile(
            leading: Icon(Icons.edit_note),
            title: const Text('Advertência'),
            onTap:() {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/advertencia');
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Relatórios'),
            onTap: () {
              Navigator.pushNamed(context, '/relatorios');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Usuário'),
            onTap: () {
              Navigator.pushNamed(context, '/usuario');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuração'),
            onTap: () {
              Navigator.pushNamed(context, '/configuracao');
            },
          )

        ],
      
      )
    );
  }
  
}