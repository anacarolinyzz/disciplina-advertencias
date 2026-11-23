
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
  String? _erro;

  List<Map<String, dynamic>> _rankingAlunos = [];
  List<Map<String, dynamic>> _rankingUsuarios = [];

  List<Advertencia> _ultimasAdvertencias = [];

  Map<String, Aluno> _alunosPorMatricula = {};

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    if (mounted) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }

    try {
      final resultados = await Future.wait([
        DadosService.instancia.listarAlunos(),
        DadosService.instancia.listarAdvertencias(),
        DadosService.instancia.listarRankingUsuarios(),
      ]);

      final List<Aluno> alunos = resultados[0] as List<Aluno>;
      final List<Advertencia> advertencias =
          resultados[1] as List<Advertencia>;

      final List<Map<String, dynamic>> rankingUsuarios =
          resultados[2] as List<Map<String, dynamic>>;

      final ranking = EstatisticasService.rankingAlunos(
        alunos,
        advertencias,
      );

      final recentes = List<Advertencia>.from(advertencias);

      recentes.sort((a, b) => b.data.compareTo(a.data));

      final alunosMap = {
        for (final aluno in alunos) aluno.matricula: aluno,
      };

      if (!mounted) return;

      setState(() {
        _totalAlunos = EstatisticasService.totalAlunos(alunos);

        _totalAdvertencias =
            EstatisticasService.totalAdvertencias(advertencias);

        _alunosComTresOuMais =
            EstatisticasService.alunosComTresOuMais(
          alunos,
          advertencias,
        );

        _advertenciasNesteMes =
            EstatisticasService.advertenciasNesteMes(advertencias);

        _rankingAlunos = ranking.take(3).toList();

        _rankingUsuarios = rankingUsuarios;

        _ultimasAdvertencias = recentes.take(4).toList();

        _alunosPorMatricula = alunosMap;

        _carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas: $e');

      if (!mounted) return;

      setState(() {
        _erro = e.toString();
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
      onTap: () => _abrirRelatorio(tipoRelatorio),
    );
  }

  List<DataRow> _construirLinhasRanking() {
    return _rankingAlunos.map((aluno) {
      return DataRow(
        cells: [
          DataCell(Text(aluno['nome']?.toString() ?? '-')),
          DataCell(Text(aluno['curso']?.toString() ?? '-')),
          DataCell(Text(aluno['turma']?.toString() ?? '-')),
          DataCell(
            Text(
              '${aluno['total'] ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<DataRow> _construirLinhasAdvertencias() {
    return _ultimasAdvertencias.map((advertencia) {
      final aluno = _alunosPorMatricula[advertencia.matriculaAluno];

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

  String _nomeMesAtual() {
    const meses = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return '${meses[DateTime.now().month - 1]} de ${DateTime.now().year}';
  }

  Widget _construirRankingUsuarios() {
    final maiorTotal = _rankingUsuarios.isEmpty
        ? 1
        : _rankingUsuarios
            .map((usuario) =>
                int.tryParse(usuario['total'].toString()) ?? 0)
            .fold<int>(0, (maior, atual) =>
                atual > maior ? atual : maior);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_outlined, size: 25),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ranking de funcionários',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              'Advertências registradas em ${_nomeMesAtual()}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            if (_carregando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_rankingUsuarios.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('Nenhum funcionário encontrado.'),
                ),
              )
            else
              ...List.generate(_rankingUsuarios.length, (index) {
                final usuario = _rankingUsuarios[index];

                final nome = usuario['nome']?.toString() ?? 'Funcionário';

                final total =
                    int.tryParse(usuario['total'].toString()) ?? 0;

                final progresso = maiorTotal == 0
                    ? 0.0
                    : total / maiorTotal;

                final medalhas = ['1º', '2º', '3º'];

                final colocacao = index < 3
                    ? medalhas[index]
                    : '${index + 1}º';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                              colocacao,
                              style: const TextStyle(fontSize: 21),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: index == 0
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: LinearProgressIndicator(
                          value: progresso,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: Colors.grey.shade200,
                          color: index == 0
                              ? Colors.amber.shade700
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const Divider(),

            const Text(
              'A classificação é atualizada conforme novas advertências são registradas.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTabelas() {
    return Column(
      children: [
        CustomTableCard(
          title: 'Alunos com mais advertências',
          columns: const [
            'Aluno',
            'Curso',
            'Turma',
            'Total',
          ],
          rows: _construirLinhasRanking(),
          onTap: () => _abrirRelatorio('maior_numero'),
        ),

        const SizedBox(height: 16),

        CustomTableCard(
          title: 'Últimas advertências',
          columns: const [
            'Data',
            'Aluno',
            'Curso',
            'Turma',
          ],
          rows: _construirLinhasAdvertencias(),
          onTap: () => _abrirRelatorio('ultimas_advertencias'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;

    final bool mobile = largura < 700;
    final bool telaAmpla = largura >= 1100;

    return Scaffold(
      appBar: AppbarPrincipal(),
      drawer: DrawerTest(),

      floatingActionButton: FloatingActionButton(
        onPressed: _abrirAdvertencia,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: RefreshIndicator(
        onRefresh: _carregarEstatisticas,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Advertências registradas',
                        _totalAdvertencias,
                        Icons.warning_amber_rounded,
                        'total_advertencias',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Alunos com 3+ advertências',
                        _alunosComTresOuMais,
                        Icons.person_outline,
                        'alunos_3plus',
                      ),
                    ),
                    const SizedBox(width: 12),
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

              const SizedBox(height: 28),

              if (_erro != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Não foi possível carregar todos os dados: $_erro',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        onPressed: _carregarEstatisticas,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),

              if (telaAmpla)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _construirTabelas(),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: _construirRankingUsuarios(),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _construirTabelas(),
                    const SizedBox(height: 20),
                    _construirRankingUsuarios(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
