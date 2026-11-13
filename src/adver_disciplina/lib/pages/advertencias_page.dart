
import 'package:flutter/material.dart';

import 'package:adver/services/dados_service.dart';
import 'package:adver/widget/appbar_principal.dart';
import 'package:adver/widget/navigation_drawer.dart';
import 'package:adver/widget/advertencia/modo_header.dart';
import 'package:adver/widget/advertencia/secao_aluno.dart';
import 'package:adver/widget/advertencia/secao_dados_advertencia.dart';







typedef AlunoMap = Map<String, String>;

class AdvertenciaPage extends StatefulWidget {
  const AdvertenciaPage({super.key});

  @override
  State<AdvertenciaPage> createState() => _AdvertenciaPageState();
}

class _AdvertenciaPageState extends State<AdvertenciaPage> {
  bool _emLote = false;

  final _dataController = TextEditingController(
    text: "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
  );
  final _descricaoController = TextEditingController();

  String? _justificativaSelecionada;
  final List<String> _justificativas = [
    'Uso de celular em sala sem autorização',
    'Ausência de fardamento/uniforme escolar',
    'Atraso injustificado',
    'Descumprimento das normas do IFPI',
    'Outro (especificar na descrição)',
  ];

  
  String? _alunoNome;
  String _alunoCurso = "Selecione o aluno";
  String _alunoTurma = "Selecione o aluno";
  String _alunoMatricula = "Selecione o aluno";

  
  List<AlunoMap> _alunosCadastrados = [];
  final List<String> _alunosEmLote = [];

  @override
  void initState() {
    super.initState();
    _carregarAlunosDoJson();
  }

  
  
Future<void> _carregarAlunosDoJson() async {
  try {
    final alunos = await DadosService.instancia.listarAlunos();

    if (!mounted) return;

    setState(() {
      _alunosCadastrados = alunos.map((aluno) {
        return {
          'nome': aluno.nome,
          'matricula': aluno.matricula,
          'curso': aluno.curso,
          'turma': aluno.turma,
        };
      }).toList();
    });

    debugPrint('Alunos carregados: ${alunos.length}');
  } catch (e) {
    debugPrint('Erro ao carregar alunos: $e');
  }
}


  void _selecionarAluno(AlunoMap aluno) {
    setState(() {
      if (_emLote) {
        if (!_alunosEmLote.contains(aluno['nome'])) {
          _alunosEmLote.add(aluno['nome']!);
        }
      } else {
        _alunoNome = aluno['nome'];
        _alunoCurso = aluno['curso']!;
        _alunoTurma = aluno['turma']!;
        _alunoMatricula = aluno['matricula']!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarPrincipal(),
      drawer: DrawerTest(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ModoHeader(
              emLote: _emLote,
              onToggleModo: () => setState(() => _emLote = !_emLote),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SecaoAluno(
                      emLote: _emLote,
                      alunoNome: _alunoNome,
                      alunosEmLote: _alunosEmLote,
                      listaAlunosCadastrados: _alunosCadastrados,
                      onAlunoSelecionado: _selecionarAluno,
                      onRemoverAlunoLote: (aluno) {
                        setState(() => _alunosEmLote.remove(aluno));
                      },
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    SecaoDadosAdvertencia(
                      emLote: _emLote,
                      dataController: _dataController,
                      descricaoController: _descricaoController,
                      justificativaSelecionada: _justificativaSelecionada,
                      justificativas: _justificativas,
                      onJustificativaChanged: (val) => setState(() => _justificativaSelecionada = val),
                      curso: _alunoCurso,
                      turma: _alunoTurma,
                      matricula: _alunoMatricula,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: _salvarEGerarPDF,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  icon: const Icon(Icons.print),
                  label: Text(_emLote ? 'Salvar e Gerar PDFs (${_alunosEmLote.length})' : 'Salvar e Gerar PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _salvarEGerarPDF() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advertência Salva!'),
        content: Text(
          _emLote
              ? 'As advertências do lote foram registradas com sucesso.'
              : 'Advertência de ${_alunoNome ?? "Aluno"} salva com sucesso.',
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
}