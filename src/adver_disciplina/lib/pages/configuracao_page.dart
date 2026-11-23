
import 'package:flutter/material.dart';

import 'package:adver/widget/navigation_drawer.dart';
import 'package:adver/pages/usuario_page.dart';
import 'package:adver/services/dados_service.dart';

class ConfiguracaoPage extends StatelessWidget {
  const ConfiguracaoPage({super.key});

  void _abrirUsuarios(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsuarioPage(),
      ),
    );
  }

  void _mostrarSobre(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o Adver'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adver',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Sistema de Gestão Disciplinar desenvolvido para '
              'auxiliar o setor de Disciplina no gerenciamento '
              'de alunos e advertências escolares.'
            ),
            SizedBox(height: 16),
            Text(
              'Desenvolvido pelos alunos: Ana Caroliny, Fabrício José, Lívia Campos e Raylane Sousa'
            ),
            Text(
              'Orientado pelo professor Sebastião Sales',
            ),
            SizedBox(height: 16),
            Text('Versão 1.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      drawer: DrawerTest(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Gerencie sua conta e consulte informações do sistema.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'CONTA CONECTADA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  elevation: 1,
                  child: FutureBuilder(
                    future: DadosService.instancia.obterUsuarioConectado(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          leading: Icon(Icons.person_outline),
                          title: Text('Carregando usuário...'),
                        );
                      }

                      final usuario = snapshot.data;

                      return ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          usuario?['nome']?.toString() ?? 'Usuário',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          usuario?['login']?.toString() ?? '',
                        ),
                        trailing: const Icon(Icons.verified_user_outlined),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'GERENCIAMENTO',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(
                      Icons.manage_accounts_outlined,
                      size: 28,
                    ),
                    title: const Text(
                      'Gerenciar usuários',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Cadastrar funcionários e editar contas existentes.',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _abrirUsuarios(context),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'SOBRE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(
                      Icons.info_outline,
                      size: 28,
                    ),
                    title: const Text(
                      'Sobre o Adver',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Informações e versão do sistema.',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _mostrarSobre(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
