
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel_plus/excel_plus.dart' hide Border;  

import 'package:adver/widget/navigation_drawer.dart';
import 'package:adver/widget/appbar_principal.dart';

import 'package:adver/models/aluno.dart';
import 'package:adver/services/dados_service.dart';

class AlunosPage extends StatefulWidget {
  const AlunosPage({super.key});

  @override
  State<AlunosPage> createState() => _AlunosPageState();
}

class _AlunosPageState extends State<AlunosPage> {
  List<Aluno> _alunos = [];
  List<Aluno> _alunosFiltrados = [];

  Map<String, int> _contagemAdvertencias = {};

  bool _carregando = true;
  bool _importando = false;

  int _totalAdvertencias = 0;

  final TextEditingController _pesquisaController =
      TextEditingController();

  String? _cursoSelecionado;
  String? _turmaSelecionada;

  final List<String> _cursos = [
    'Administração',
    'Agropecuária',
    'Informática',
    'Mineração',
  ];

  @override
  void initState() {
    super.initState();
    _carregarAlunos();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }


  String _normalizarTexto(String texto) {
    return texto
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }

  bool _alunoPertenceAoCurso(Aluno aluno, String curso) {
    return _normalizarTexto(aluno.curso)
        .contains(_normalizarTexto(curso));
  }



  Future<void> _carregarAlunos() async {
    try {
      final alunos =
          await DadosService.instancia.listarAlunos();

      final advertencias =
          await DadosService.instancia.listarAdvertencias();

      // Conta quantas advertências cada matrícula possui.
      final Map<String, int> contagem = {};

      for (final advertencia in advertencias) {
        contagem.update(
          advertencia.matriculaAluno,
          (quantidade) => quantidade + 1,
          ifAbsent: () => 1,
        );
      }

      if (!mounted) return;

      setState(() {
        _alunos = alunos;
        _contagemAdvertencias = contagem;
        _totalAdvertencias = advertencias.length;
        _carregando = false;

        _atualizarLista();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      _mostrarMensagem('Erro ao carregar os alunos: $e');
    }
  }


  List<String> get _turmasDisponiveis {
    final alunosDoCurso = _cursoSelecionado == null
        ? _alunos
        : _alunos.where(
            (aluno) => _alunoPertenceAoCurso(
              aluno,
              _cursoSelecionado!,
            ),
          ).toList();

    final turmas = alunosDoCurso
        .map((aluno) => aluno.turma.trim())
        .where((turma) => turma.isNotEmpty)
        .toSet()
        .toList();

    turmas.sort(
      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );

    return turmas;
  }

  void _atualizarLista() {
    final pesquisa =
        _normalizarTexto(_pesquisaController.text);

    final resultado = _alunos.where((aluno) {
      // Pesquisa por nome ou matrícula.
      final correspondePesquisa =
          pesquisa.isEmpty ||
          _normalizarTexto(aluno.nome).contains(pesquisa) ||
          _normalizarTexto(aluno.matricula).contains(pesquisa);

      // Filtro por curso.
      final correspondeCurso =
          _cursoSelecionado == null ||
          _alunoPertenceAoCurso(
            aluno,
            _cursoSelecionado!,
          );

      // Filtro por turma.
      final correspondeTurma =
          _turmaSelecionada == null ||
          _normalizarTexto(aluno.turma) ==
              _normalizarTexto(_turmaSelecionada!);

      return correspondePesquisa &&
          correspondeCurso &&
          correspondeTurma;
    }).toList();

    // Ordena os alunos pelo nome
    resultado.sort(
      (a, b) => _normalizarTexto(a.nome)
          .compareTo(_normalizarTexto(b.nome)),
    );

    _alunosFiltrados = resultado;
  }

  void _pesquisarAlunos(String texto) {
    setState(() {
      _atualizarLista();
    });
  }

  void _selecionarCurso(String? curso) {
    setState(() {
      _cursoSelecionado = curso;

      // Reinicia a turma ao trocar de curso
      _turmaSelecionada = null;

      _atualizarLista();
    });
  }

  void _selecionarTurma(String? turma) {
    setState(() {
      _turmaSelecionada = turma;
      _atualizarLista();
    });
  }

  void _limparFiltros() {
    setState(() {
      _cursoSelecionado = null;
      _turmaSelecionada = null;
      _pesquisaController.clear();

      _atualizarLista();
    });
  }

 

  String _obterTextoCelula(dynamic celula) {
    final valor = celula?.value;

    if (valor == null) {
      return '';
    }

    return switch (valor) {
      TextCellValue() => valor.value.toString(),

      IntCellValue(:final value) =>
        value.toString(),

      DoubleCellValue(:final value) =>
        value.toString().replaceAll(RegExp(r'\.0$'), ''),

      BoolCellValue(:final value) =>
        value.toString(),

      DateCellValue() =>
        valor.asDateTimeLocal().toString().split(' ').first,

      DateTimeCellValue() =>
        valor.asDateTimeLocal().toString(),

      TimeCellValue() =>
        valor.asDuration().toString(),

      FormulaCellValue(:final formula) =>
        formula,

      CellErrorValue() =>
        valor.toString(),

      _ => valor.toString(),
    };
  }



  String _normalizarCabecalho(String texto) {
    return texto
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  int _encontrarColuna(
    List<String> cabecalhos,
    List<String> alternativas,
  ) {
    for (int i = 0; i < cabecalhos.length; i++) {
      if (alternativas.contains(cabecalhos[i])) {
        return i;
      }
    }

    return -1;
  }


  // excel
  

  Future<void> _importarAlunos() async {
    try {
      final arquivo = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (arquivo == null) return;

      if (!mounted) return;

      setState(() {
        _importando = true;
      });

      final bytes = await arquivo.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('O arquivo selecionado está vazio.');
      }

      final planilha = Excel.decodeBytes(bytes);

      if (planilha.tables.isEmpty) {
        throw Exception('A planilha não possui abas.');
      }

      final nomeAba = planilha.tables.keys.first;
      final aba = planilha.tables[nomeAba];

      if (aba == null || aba.rows.isEmpty) {
        throw Exception('A planilha está vazia.');
      }

      // Identifica as colunas
      final cabecalhos = aba.rows.first.map((celula) {
        return _normalizarCabecalho(
          _obterTextoCelula(celula),
        );
      }).toList();

      final colunaMatricula = _encontrarColuna(
        cabecalhos,
        [
          'matricula',
          'matriculaaluno',
          'matriculadoaluno',
        ],
      );

      final colunaNome = _encontrarColuna(
        cabecalhos,
        [
          'nome',
          'nomealuno',
          'nomedoaluno',
        ],
      );

      final colunaCurso = _encontrarColuna(
        cabecalhos,
        [
          'curso',
          'nomedocurso',
          'cursodoaluno',
        ],
      );

      final colunaTurma = _encontrarColuna(
        cabecalhos,
        [
          'turma',
          'nometurma',
          'turmadoaluno',
        ],
      );

      if (colunaMatricula == -1 ||
          colunaNome == -1 ||
          colunaCurso == -1 ||
          colunaTurma == -1) {
        throw Exception(
          'Não encontrei todas as colunas obrigatórias. '
          'A planilha precisa ter matrícula, nome, curso e turma.',
        );
      }

      // Lê os alunos
      final alunosImportados = <Aluno>[];
      final matriculasEncontradas = <String>{};

      int linhasInvalidas = 0;
      int linhasDuplicadas = 0;

      for (int i = 1; i < aba.rows.length; i++) {
        final linha = aba.rows[i];

        String obterValor(int indice) {
          if (indice >= linha.length) {
            return '';
          }

          return _obterTextoCelula(
            linha[indice],
          ).trim();
        }

        final matricula = obterValor(colunaMatricula);
        final nome = obterValor(colunaNome);
        final curso = obterValor(colunaCurso);
        final turma = obterValor(colunaTurma);

        // Ignora linhas totalmente vazias
        if (matricula.isEmpty &&
            nome.isEmpty &&
            curso.isEmpty &&
            turma.isEmpty) {
          continue;
        }

        // Ignora registros incompletos
        if (matricula.isEmpty ||
            nome.isEmpty ||
            curso.isEmpty ||
            turma.isEmpty) {
          linhasInvalidas++;
          continue;
        }

        // Evita matrículas repetidas no arquivo
        if (!matriculasEncontradas.add(matricula)) {
          linhasDuplicadas++;
          continue;
        }

        alunosImportados.add(
          Aluno(
            matricula: matricula,
            nome: nome,
            curso: curso,
            turma: turma,
          ),
        );
      }

      if (alunosImportados.isEmpty) {
        throw Exception(
          'Nenhum aluno válido foi encontrado na planilha.',
        );
      }

      // Salva os alunos
      final resultado =
          await DadosService.instancia.importarAlunos(
        alunosImportados,
      );

      await _carregarAlunos();

      if (!mounted) return;

      setState(() {
        _importando = false;
      });

      _mostrarResultadoImportacao(
        novos: resultado['novos'] ?? 0,
        atualizados: resultado['atualizados'] ?? 0,
        invalidos: linhasInvalidas,
        duplicados: linhasDuplicadas,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _importando = false;
      });

      _mostrarMensagem(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

 

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarResultadoImportacao({
    required int novos,
    required int atualizados,
    required int invalidos,
    required int duplicados,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importação concluída'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Novos alunos: $novos'),
              const SizedBox(height: 8),
              Text('Alunos atualizados: $atualizados'),
              const SizedBox(height: 8),
              Text('Linhas incompletas ignoradas: $invalidos'),
              const SizedBox(height: 8),
              Text('Matrículas repetidas ignoradas: $duplicados'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

 

  Widget _construirPesquisa() {
    return SizedBox(
      width: 350,
      child: TextField(
        controller: _pesquisaController,
        onChanged: _pesquisarAlunos,
        decoration: InputDecoration(
          hintText: 'Pesquisar por nome ou matrícula...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Limpar pesquisa',
            onPressed: () {
              _pesquisaController.clear();
              _pesquisarAlunos('');
            },
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }



  Widget _construirFiltroCurso() {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        value: _cursoSelecionado,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Curso',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.school_outlined),
        ),
        hint: const Text('Todos os cursos'),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Todos os cursos'),
          ),
          ..._cursos.map((curso) {
            return DropdownMenuItem<String>(
              value: curso,
              child: Text(curso),
            );
          }),
        ],
        onChanged: _selecionarCurso,
      ),
    );
  }

  

  Widget _construirFiltroTurma() {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        value: _turmaSelecionada,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Turma',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.groups_outlined),
        ),
        hint: const Text('Todas as turmas'),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Todas as turmas'),
          ),
          ..._turmasDisponiveis.map((turma) {
            return DropdownMenuItem<String>(
              value: turma,
              child: Text(turma),
            );
          }),
        ],
        onChanged: _selecionarTurma,
      ),
    );
  }

  

  Widget _construirTabela() {
    if (_alunosFiltrados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('Nenhum aluno encontrado.'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 48,
        dataRowMaxHeight: 56,
        columnSpacing: 35,
        columns: const [
          DataColumn(
            label: Text('Matrícula'),
          ),
          DataColumn(
            label: Text('Nome'),
          ),
          DataColumn(
            label: Text('Curso'),
          ),
          DataColumn(
            label: Text('Turma'),
          ),
          DataColumn(
            label: Text('Advertências'),
            numeric: true,
          ),
        ],
        rows: _alunosFiltrados.map((aluno) {
          final quantidade =
              _contagemAdvertencias[aluno.matricula] ?? 0;

          return DataRow(
            cells: [
              DataCell(Text(aluno.matricula)),
              DataCell(Text(aluno.nome)),
              DataCell(Text(aluno.curso)),
              DataCell(Text(aluno.turma)),
              DataCell(
                Text(
                  quantidade.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: quantidade >= 3
                        ? Colors.red
                        : quantidade > 0
                            ? Colors.orange.shade800
                            : null,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPrincipal(),
      drawer: DrawerTest(),

      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título e botão de importação.
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alunos',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: _importando
                            ? null
                            : _importarAlunos,
                        icon: _importando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(
                          _importando
                              ? 'Importando...'
                              : 'Importar alunos',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Consulte os alunos e acompanhe suas advertências.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Indicadores
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      _construirIndicador(
                        'Total de alunos',
                        _alunos.length.toString(),
                        Icons.people_outline,
                      ),
                      _construirIndicador(
                        'Total de advertências',
                        _totalAdvertencias.toString(),
                        Icons.assignment_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // pesquisa e filtros
                  const Text(
                    'Buscar e filtrar alunos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment:
                        WrapCrossAlignment.center,
                    children: [
                      _construirPesquisa(),
                      _construirFiltroCurso(),
                      _construirFiltroTurma(),

                      OutlinedButton.icon(
                        onPressed: _limparFiltros,
                        icon: const Icon(Icons.filter_alt_off),
                        label: const Text('Limpar filtros'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Alunos encontrados: ${_alunosFiltrados.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tabela.
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lista de alunos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          _construirTabela(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }



  Widget _construirIndicador(
    String titulo,
    String valor,
    IconData icone,
  ) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icone,
            size: 30,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
