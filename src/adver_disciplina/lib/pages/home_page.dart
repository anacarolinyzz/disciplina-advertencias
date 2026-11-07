import 'package:flutter/material.dart';
import 'package:adver/widget/navigation_drawer.dart';
import 'package:adver/widget/appbar_principal.dart';
import 'package:adver/widget/stat_card.dart';
import 'package:adver/widget/tabela.dart';



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarPrincipal(),
      drawer:  DrawerTest(),
      
      //adicionar avertência botão rápido
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Redireciona para a tela de registro de advertência
          Navigator.pushNamed(context, '/advertencia');
        },
        backgroundColor: Theme.of(context).cardColor,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nova Advertência',
          style: TextStyle( fontWeight: FontWeight.bold),
        ),
      ),

      // tela
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Boas-Vindas
                Text(
                  'Olá Edmarcos!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bem-vindo ao sistema Adver.',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. StatCards (Empilhados no Mobile, 4 Colunas no Desktop)
                if (isMobile) ...[
                  const StatCard(title: 'Total de alunos', value: '489', icon: Icons.groups),
                  const SizedBox(height: 12),
                  const StatCard(title: 'Advertências registradas', value: '122', icon: Icons.warning_amber_rounded),
                  const SizedBox(height: 12),
                  const StatCard(title: 'Alunos com 3+ advertências', value: '12', icon: Icons.person_outline),
                  const SizedBox(height: 12),
                  const StatCard(title: 'Advertências neste mês', value: '21', icon: Icons.calendar_today),
                ] else
                  const Row(
                    children: [
                      Expanded(child: StatCard(title: 'Total de alunos', value: '489', icon: Icons.groups)),
                      SizedBox(width: 16),
                      Expanded(child: StatCard(title: 'Advertências registradas', value: '122', icon: Icons.warning_amber_rounded)),
                      SizedBox(width: 16),
                      Expanded(child: StatCard(title: 'Alunos com 3+ advertências', value: '12', icon: Icons.person_outline)),
                      SizedBox(width: 16),
                      Expanded(child: StatCard(title: 'Advertências neste mês', value: '21', icon: Icons.calendar_today)),
                    ],
                  ),

                const SizedBox(height: 24),

                // 3. TABELAS (Agora ocupam 100% da largura!)
                CustomTableCard(
                  title: 'Alunos com maior número de advertência',
                  onTap: () => Navigator.pushNamed(context, '/relatorios', arguments: 'maior_numero'),
                  columns: const ['Aluno', 'Curso', 'Turma', 'Total de advertências'],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('Ana Maria')),
                      DataCell(Text('Informática')),
                      DataCell(Text('2º')),
                      DataCell(Text('8', style: TextStyle(fontWeight: FontWeight.bold))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Emylly Lorrany')),
                      DataCell(Text('Informática')),
                      DataCell(Text('2º')),
                      DataCell(Text('6', style: TextStyle(fontWeight: FontWeight.bold))),
                    ]),
                  ],
                ),

                const SizedBox(height: 24),

                CustomTableCard(
                  title: 'Últimas advertências registradas',
                  onTap: () => Navigator.pushNamed(context, '/relatorios', arguments: 'ultimas_advertencias'),
                  columns: const ['Data', 'Aluno', 'Curso', 'Turma'],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('04/09/2026')),
                      DataCell(Text('João Silva')),
                      DataCell(Text('Informática')),
                      DataCell(Text('2º A')),
                    ]),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}