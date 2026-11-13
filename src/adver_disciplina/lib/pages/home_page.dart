
import 'package:flutter/material.dart';

import 'package:adver/widget/navigation_drawer.dart';
import 'package:adver/widget/appbar_principal.dart';
import 'package:adver/widget/home/stat_card.dart';
import 'package:adver/widget/home/tabela.dart';

import 'package:adver/models/aluno.dart';
import 'package:adver/models/advertencia.dart';

import 'package:adver/services/dados_service.dart';
import 'package:adver/services/estatisticas_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalAlunos = 0;
  int _totalAdvertencias = 0;
  int _alunosComTresOuMais = 0;
  int _advertenciasNesteMes = 0;

  bool _carregando = true;

  List<Map<String, dynamic>> _rankingAlunos = [];

  List<Advertencia> _ultimasAdvertencias = [];

  Map<String, Aluno> _alunosPorMatricula = {};

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    try {
      final List<Aluno> alunos =
          await DadosService.instancia.listarAlunos();

      final List<Advertencia> advertencias =
          await DadosService.instancia.listarAdvertencias();

      final ranking = EstatisticasService.rankingAlunos(
        alunos,
        advertencias,
      );

      // Organiza as advertências da mais recente para a mais antiga.
      final recentes = List<Advertencia>.from(advertencias);

      recentes.sort((a, b) {
        return b.data.compareTo(a.data);
      });

      final alunosMap = {
        for (final aluno in alunos)
          aluno.matricula: aluno,
      };

      if (!mounted) return;

      setState(() {
        _totalAlunos =
            EstatisticasService.totalAlunos(alunos);

        _totalAdvertencias =
            EstatisticasService.totalAdvertencias(advertencias);

        _alunosComTresOuMais =
            EstatisticasService.alunosComTresOuMais(
          alunos,
          advertencias,
        );

        _advertenciasNesteMes =
            EstatisticasService.advertenciasNesteMes(
          advertencias,
        );

        _rankingAlunos = ranking.take(5).toList();

        _ultimasAdvertencias = recentes.take(5).toList();

        _alunosPorMatricula = alunosMap;

        _carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas: $e');

      if (!mounted) return;

      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _abrirAdvertencia() async {
    final resultado = await Navigator.pushNamed(
      context,
      '/advertencia',
    );

    if (resultado == true) {
      await _carregarEstatisticas();
    }
  }

  void _abrirRelatorio(String tipo) {
    Navigator.pushNamed(
      context,
      '/relatorios',
      arguments: tipo,
    );
  }

  // Constroi os cards de estatísticas
  Widget _buildStatCard(
    String titulo,
    int valor,
    IconData icone,
    String tipoRelatorio,
  ) {
    return StatCard(
      title: titulo,
      value: _carregando ? '...' : valor.toString(),
      icon: icone,
      onTap: () {
        _abrirRelatorio(tipoRelatorio);
      },
    );
  }

  // Monta as linhas do ranking
  List<DataRow> _construirLinhasRanking() {
    return _rankingAlunos.map((aluno) {
      return DataRow(
        cells: [
          DataCell(Text(aluno['nome'])),
          DataCell(Text(aluno['curso'])),
          DataCell(Text(aluno['turma'])),
          DataCell(
            Text(
              '${aluno['total']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  // Monta as linhas das últimas advertências
  List<DataRow> _construirLinhasAdvertencias() {
    return _ultimasAdvertencias.map((advertencia) {
      final aluno = _alunosPorMatricula[
        advertencia.matriculaAluno
      ];

      final nomeAluno = aluno?.nome ?? 'Aluno não encontrado';

      final dataFormatada =
          '${advertencia.data.day.toString().padLeft(2, '0')}/'
          '${advertencia.data.month.toString().padLeft(2, '0')}/'
          '${advertencia.data.year}';

      return DataRow(
        cells: [
          DataCell(Text(dataFormatada)),
          DataCell(Text(nomeAluno)),
          DataCell(Text(aluno?.curso ?? '-')),
          DataCell(Text(aluno?.turma ?? '-')),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    final bool mobile = largura < 700;

    return Scaffold(
      appBar: AppbarPrincipal(),
      drawer: DrawerTest(),

      floatingActionButton: FloatingActionButton(
        onPressed: _abrirAdvertencia,
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Visão geral',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Cards De Estatística

            if (mobile)
              Column(
                children: [
                  _buildStatCard(
                    'Total de alunos',
                    _totalAlunos,
                    Icons.groups,
                    'total_alunos',
                  ),

                  const SizedBox(height: 12),

                  _buildStatCard(
                    'Advertências registradas',
                    _totalAdvertencias,
                    Icons.warning_amber_rounded,
                    'total_advertencias',
                  ),

                  const SizedBox(height: 12),

                  _buildStatCard(
                    'Alunos com 3+ advertências',
                    _alunosComTresOuMais,
                    Icons.person_outline,
                    'alunos_3plus',
                  ),

                  const SizedBox(height: 12),

                  _buildStatCard(
                    'Advertências neste mês',
                    _advertenciasNesteMes,
                    Icons.calendar_today,
                    'advertencias_mes',
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total de alunos',
                      _totalAlunos,
                      Icons.groups,
                      'total_alunos',
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _buildStatCard(
                      'Advertências registradas',
                      _totalAdvertencias,
                      Icons.warning_amber_rounded,
                      'total_advertencias',
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _buildStatCard(
                      'Alunos com 3+ advertências',
                      _alunosComTresOuMais,
                      Icons.person_outline,
                      'alunos_3plus',
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _buildStatCard(
                      'Advertências neste mês',
                      _advertenciasNesteMes,
                      Icons.calendar_today,
                      'advertencias_mes',
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // RANKING DE ALUNOS

            CustomTableCard(
              title: 'Alunos com maior número de advertências',
              columns: const [
                'Aluno',
                'Curso',
                'Turma',
                'Total',
              ],
              rows: _construirLinhasRanking(),
              onTap: () {
                _abrirRelatorio('maior_numero');
              },
            ),

            const SizedBox(height: 20),

            // últimas advertências

            CustomTableCard(
              title: 'Últimas advertências registradas',
              columns: const [
                'Data',
                'Aluno',
                'Curso',
                'Turma',
              ],
              rows: _construirLinhasAdvertencias(),
              onTap: () {
                _abrirRelatorio('ultimas_advertencias');
              },
            ),
          ],
        ),
      ),
    );
  }
}
