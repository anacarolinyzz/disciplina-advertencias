import 'package:flutter/material.dart';

import 'package:adver/widget/navigation_drawer.dart';
import 'package:adver/widget/appbar_principal.dart';

import 'package:adver/models/aluno.dart';
import 'package:adver/models/advertencia.dart';
import 'package:adver/services/dados_service.dart';
import 'package:adver/services/relatorio_service.dart';

import 'package:adver/widget/relatorios/selecao_tipo_relatorio.dart';
import 'package:adver/widget/relatorios/filtros.dart';
import 'package:adver/widget/relatorios/resumo_relatorio.dart';
import 'package:adver/widget/relatorios/tabela_relatorio.dart';

class RelatorioPage extends StatefulWidget {
  const RelatorioPage({super.key});

  @override
  State<RelatorioPage> createState() => _RelatorioPageState();
}

class _RelatorioPageState extends State<RelatorioPage> {
  List<Aluno> _alunos = [];
  List<Advertencia> _advertencias = [];

  bool _carregando = true;
  String? _erro;

  String _tipoRelatorio = 'Turma';
  String _cursoSelecionado = 'Todos';
  String _turmaSelecionada = 'Todas';
  int _quantidadeMinima = 1;

  DateTimeRange? _periodoSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final alunos = await DadosService.instancia.listarAlunos();
      final advertencias =
          await DadosService.instancia.listarAdvertencias();

      if (!mounted) return;

      setState(() {
        _alunos = alunos;
        _advertencias = advertencias;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível carregar os dados.';
        _carregando = false;
      });
    }
  }

  List<String> get _cursos {
    final cursos = _alunos.map((aluno) => aluno.curso).toSet().toList();
    cursos.sort();
    return cursos;
  }

  List<String> get _turmas {
    final alunos = _alunos.where((aluno) {
      return _cursoSelecionado == 'Todos' ||
          aluno.curso == _cursoSelecionado;
    });

    final turmas = alunos.map((aluno) => aluno.turma).toSet().toList();
    turmas.sort();
    return turmas;
  }

  List<Aluno> get _alunosFiltrados {
    return _alunos.where((aluno) {
      final cursoCorreto = _cursoSelecionado == 'Todos' ||
          aluno.curso == _cursoSelecionado;

      final turmaCorreta = _turmaSelecionada == 'Todas' ||
          aluno.turma == _turmaSelecionada;

      return cursoCorreto && turmaCorreta;
    }).toList();
  }

  List<Advertencia> get _advertenciasFiltradas {
    final matriculas = _alunosFiltrados
        .map((aluno) => aluno.matricula)
        .toSet();

    return _advertencias.where((advertencia) {
      final alunoCorreto =
          matriculas.contains(advertencia.matriculaAluno);

      final data = advertencia.data;
      final periodoCorreto = _periodoSelecionado == null ||
          (!data.isBefore(_periodoSelecionado!.start) &&
              data.isBefore(
                DateTime(
                  _periodoSelecionado!.end.year,
                  _periodoSelecionado!.end.month,
                  _periodoSelecionado!.end.day + 1,
                ),
              ));

      return alunoCorreto && periodoCorreto;
    }).toList();
  }

  Map<String, int> get _contagemPorAluno {
    final contagem = <String, int>{};

    for (final advertencia in _advertenciasFiltradas) {
      final matricula = advertencia.matriculaAluno;
      contagem[matricula] = (contagem[matricula] ?? 0) + 1;
    }

    return contagem;
  }

  List<Advertencia> _advertenciasParaRelatorio() {
    final advertencias = List<Advertencia>.from(_advertenciasFiltradas);
    final contagem = _contagemPorAluno;

    // No relatório por quantidade, considera apenas alunos que
    // atingiram a quantidade mínima selecionada.
    if (_tipoRelatorio == 'Quantidade') {
      advertencias.removeWhere((advertencia) {
        return (contagem[advertencia.matriculaAluno] ?? 0) <
            _quantidadeMinima;
      });
    }

    final alunosPorMatricula = {
      for (final aluno in _alunos) aluno.matricula: aluno,
    };

    advertencias.sort((a, b) {
      final alunoA = alunosPorMatricula[a.matriculaAluno];
      final alunoB = alunosPorMatricula[b.matriculaAluno];

      switch (_tipoRelatorio) {
        case 'Turma':
          final curso =
              (alunoA?.curso ?? '').compareTo(alunoB?.curso ?? '');
          if (curso != 0) return curso;

          final turma =
              (alunoA?.turma ?? '').compareTo(alunoB?.turma ?? '');
          if (turma != 0) return turma;

          return b.data.compareTo(a.data);

        case 'Curso':
          final curso =
              (alunoA?.curso ?? '').compareTo(alunoB?.curso ?? '');
          if (curso != 0) return curso;

          return b.data.compareTo(a.data);

        case 'Quantidade':
          final quantidadeA = contagem[a.matriculaAluno] ?? 0;
          final quantidadeB = contagem[b.matriculaAluno] ?? 0;

          final comparacao = quantidadeB.compareTo(quantidadeA);
          if (comparacao != 0) return comparacao;

          return b.data.compareTo(a.data);

        default:
          return b.data.compareTo(a.data);
      }
    });

    return advertencias;
  }

  List<DataRow> _linhasRelatorio() {
    final advertencias = _advertenciasParaRelatorio();

    final alunosPorMatricula = {
      for (final aluno in _alunos) aluno.matricula: aluno,
    };

    return advertencias.map((advertencia) {
      final aluno = alunosPorMatricula[advertencia.matriculaAluno];
      final quantidade =
          _contagemPorAluno[advertencia.matriculaAluno] ?? 0;

      return DataRow(cells: [
        DataCell(Text(_formatarData(advertencia.data))),
        DataCell(Text(aluno?.nome ?? 'Aluno não encontrado')),
        DataCell(Text(aluno?.curso ?? '-')),
        DataCell(Text(aluno?.turma ?? '-')),
        DataCell(
          SizedBox(
            width: 220,
            child: Text(
              advertencia.justificativa,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Text(
            '$quantidade',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]);
    }).toList();
  }

  List<DataColumn> _colunasRelatorio() {
    return const [
      DataColumn(label: Text('Data')),
      DataColumn(label: Text('Aluno')),
      DataColumn(label: Text('Curso')),
      DataColumn(label: Text('Turma')),
      DataColumn(label: Text('Justificativa')),
      DataColumn(label: Text('Quantidade')),
    ];
  }

  int get _totalAdvertencias => _advertenciasParaRelatorio().length;

  int get _totalAlunosEnvolvidos {
    return _advertenciasParaRelatorio()
        .map((advertencia) => advertencia.matriculaAluno)
        .toSet()
        .length;
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  String get _textoPeriodo {
    if (_periodoSelecionado == null) return 'Selecionar período';

    return '${_formatarData(_periodoSelecionado!.start)} - '
        '${_formatarData(_periodoSelecionado!.end)}';
  }

  Future<void> _selecionarPeriodo() async {
    final periodo = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: _periodoSelecionado,
      helpText: 'Selecione o período do relatório',
      saveText: 'Confirmar',
      cancelText: 'Cancelar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (periodo != null) {
      setState(() {
        _periodoSelecionado = periodo;
      });
    }
  }

  void _limparFiltros() {
    setState(() {
      _cursoSelecionado = 'Todos';
      _turmaSelecionada = 'Todas';
      _periodoSelecionado = null;
      _quantidadeMinima = 1;
    });
  }

  Future<void> _gerarPdf() async {
    final advertencias = _advertenciasParaRelatorio();

    if (advertencias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não existem registros para gerar o relatório.'),
        ),
      );
      return;
    }

    final alunosPorMatricula = {
      for (final aluno in _alunos) aluno.matricula: aluno,
    };

    final periodo = _periodoSelecionado == null
        ? 'Todo o período'
        : '${_formatarData(_periodoSelecionado!.start)} até '
            '${_formatarData(_periodoSelecionado!.end)}';

    try {
      await RelatorioService.gerarPdf(
        advertencias: advertencias,
        alunosPorMatricula: alunosPorMatricula,
        contagemPorAluno: _contagemPorAluno,
        tipoRelatorio: _tipoRelatorio,
        cursoSelecionado: _cursoSelecionado,
        turmaSelecionada: _turmaSelecionada,
        quantidadeMinima: _quantidadeMinima,
        periodo: periodo,
        formatarData: _formatarData,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível gerar o PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPrincipal(),
      drawer: DrawerTest(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _carregando ? null : _gerarPdf,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Gerar relatório em PDF'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Relatórios',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Consulte e analise os registros de advertências.',
                      ),
                      const SizedBox(height: 24),

                      SelecaoTipoRelatorio(
                        valor: _tipoRelatorio,
                        aoAlterar: (valor) {
                          setState(() {
                            _tipoRelatorio = valor;
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      FiltrosRelatorio(
                        cursoSelecionado: _cursoSelecionado,
                        turmaSelecionada: _turmaSelecionada,
                        cursos: _cursos,
                        turmas: _turmas,
                        textoPeriodo: _textoPeriodo,
                        tipoRelatorio: _tipoRelatorio,
                        quantidadeMinima: _quantidadeMinima,
                        aoAlterarCurso: (valor) {
                          if (valor == null) return;
                          setState(() {
                            _cursoSelecionado = valor;
                            _turmaSelecionada = 'Todas';
                          });
                        },
                        aoAlterarTurma: (valor) {
                          if (valor == null) return;
                          setState(() {
                            _turmaSelecionada = valor;
                          });
                        },
                        aoSelecionarPeriodo: _selecionarPeriodo,
                        aoAlterarQuantidade: (valor) {
                          if (valor == null) return;
                          setState(() {
                            _quantidadeMinima = valor;
                          });
                        },
                        aoLimpar: _limparFiltros,
                      ),

                      const SizedBox(height: 24),
                      ResumoRelatorio(
                        totalAdvertencias: _totalAdvertencias,
                        totalAlunosEnvolvidos: _totalAlunosEnvolvidos,
                      ),

                      const SizedBox(height: 24),
                      TabelaRelatorio(
                        linhas: _linhasRelatorio(),
                        colunas: _colunasRelatorio(),
                      ),
                    ],
                  ),
                ),
    );
  }
}
