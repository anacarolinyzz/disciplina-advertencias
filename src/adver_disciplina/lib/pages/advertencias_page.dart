import 'package:flutter/material.dart';

import 'package:adver/services/dados_service.dart';
import 'package:adver/widget/appbar_principal.dart';
import 'package:adver/widget/navigation_drawer.dart';
import 'package:adver/widget/advertencia/modo_header.dart';
import 'package:adver/widget/advertencia/secao_aluno.dart';
import 'package:adver/widget/advertencia/secao_dados_advertencia.dart';
import 'package:adver/models/advertencia.dart';
import 'package:adver/services/pdf_service.dart';
import 'package:adver/services/zip_service.dart';
import 'package:adver/models/justificativas_legais.dart';






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

  String? _tipoSelecionado;
String? _justificativaSelecionada;

List<String> get _justificativas =>
    JustificativasLegais.obterTextos(_tipoSelecionado);

  
  String? _alunoNome;
  String _alunoCurso = "Selecione o aluno";
  String _alunoTurma = "Selecione o aluno";
  String _alunoMatricula = "Selecione o aluno";
  bool _salvando = false;

  
  List<AlunoMap> _alunosCadastrados = [];
  final List<AlunoMap> _alunosEmLote = [];

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
      final matricula = aluno['matricula'];

      final jaSelecionado = _alunosEmLote.any(
        (item) => item['matricula'] == matricula,
      );

      if (!jaSelecionado) {
        _alunosEmLote.add(aluno);
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
                      onRemoverAlunoLote: (matricula) {
                         setState(() {
                          _alunosEmLote.removeWhere(
                          (aluno) => aluno['matricula'] == matricula,
                        );
                     });
                    },
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    SecaoDadosAdvertencia(
  emLote: _emLote,
  dataController: _dataController,
  descricaoController: _descricaoController,

  tipoSelecionado: _tipoSelecionado,
  onTipoChanged: (tipo) {
    setState(() {
      _tipoSelecionado = tipo;
      _justificativaSelecionada = null;
    });
  },

  justificativaSelecionada: _justificativaSelecionada,
  justificativas: _justificativas,
  onJustificativaChanged: (valor) {
    setState(() {
      _justificativaSelecionada = valor;
    });
  },

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
                  onPressed: _salvando ? null : _salvarEGerarPDF,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  icon: const Icon(Icons.print),
                  label: Text(
  _salvando
      ? 'Salvando...'
      : _emLote
          ? 'Salvar e Gerar PDFs (${_alunosEmLote.length})'
          : 'Salvar e Gerar PDF',
),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }




Future<void> _salvarAdvertenciasEmLote() async {
  if (_salvando) return;

  if (_alunosEmLote.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selecione pelo menos um aluno.'),
      ),
    );
    return;
  }

  if (_justificativaSelecionada == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selecione uma justificativa.'),
      ),
    );
    return;
  }

  if (_descricaoController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preencha a descrição.'),
      ),
    );
    return;
  }
  if (_tipoSelecionado == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Selecione o tipo de medida disciplinar.'),
    ),
  );
  return;
}

  DateTime data;

  try {
    final partes = _dataController.text.split('/');

    if (partes.length != 3) {
      throw FormatException();
    }

    data = DateTime(
      int.parse(partes[2]),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );

    if (data.day != int.parse(partes[0]) ||
        data.month != int.parse(partes[1]) ||
        data.year != int.parse(partes[2])) {
      throw FormatException();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informe uma data válida.'),
      ),
    );
    return;
  }

  // Guardar os dados antes de iniciar o processo.
  final alunosSelecionados = List<AlunoMap>.from(_alunosEmLote);

  final matriculas = alunosSelecionados
      .map((aluno) => aluno['matricula']!)
      .toList();

  final justificativa = _justificativaSelecionada!;
  final descricao = _descricaoController.text.trim();

  setState(() {
    _salvando = true;
  });

  try {
    // 1. Registrar todas as advertências no banco de dados.
    final registros =
        await DadosService.instancia.salvarAdvertenciasEmLote(
      matriculas: matriculas,
      data: data,
      justificativa: justificativa,
      descricao: descricao,
    );

    // 2. Gerar os PDFs e baixar um único arquivo ZIP.
    List<String> pdfsComErro;

    try {
      pdfsComErro = await ZipService.gerarEbaixarAdvertencias(
  alunos: alunosSelecionados,
  data: data,
  justificativa: justificativa,
  descricao: descricao,
  tipoMedida: _tipoSelecionado!,
);
    } catch (erroZip) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${registros.length} advertência(s) foram salvas, '
            'mas houve um erro ao gerar ou baixar o ZIP: $erroZip',
          ),
          duration: const Duration(seconds: 8),
        ),
      );
      return;
    }

    if (!mounted) return;

    // 3. Apresentar o resultado.
    final quantidadeSalva = registros.length;
    final quantidadePdf =
        alunosSelecionados.length - pdfsComErro.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Processo concluído!'),
        content: Text(
          pdfsComErro.isEmpty
              ? '$quantidadeSalva advertência(s) foram registradas '
                  'e $quantidadePdf PDF(s) foram incluídos no ZIP. '
                  'O download foi iniciado.'
              : '$quantidadeSalva advertência(s) foram registradas. '
                  '$quantidadePdf PDF(s) foram incluídos no ZIP e o '
                  'download foi iniciado. Não foi possível gerar os '
                  'PDFs de: ${pdfsComErro.join(', ')}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _limparFormulario();
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao registrar advertências: $e'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _salvando = false;
      });
    }
  }
}




  
Future<void> _salvarEGerarPDF() async {
  if (_emLote) {
    await _salvarAdvertenciasEmLote();
    return;
  }

  if (_salvando) return;

  // Validações
  if (_alunoNome == null ||
      _alunoMatricula == 'Selecione o aluno') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selecione um aluno.')),
    );
    return;
  }

  if (_justificativaSelecionada == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selecione uma justificativa.')),
    );
    return;
  }

  if (_descricaoController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preencha a descrição.')),
    );
    return;
  }
  if (_tipoSelecionado == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Selecione o tipo de medida disciplinar.'),
    ),
  );
  return;
}

  // Converter data
  DateTime data;

  try {
    final partes = _dataController.text.split('/');

    if (partes.length != 3) {
      throw FormatException();
    }

    data = DateTime(
      int.parse(partes[2]),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );

    if (data.day != int.parse(partes[0]) ||
        data.month != int.parse(partes[1]) ||
        data.year != int.parse(partes[2])) {
      throw FormatException();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informe uma data válida.')),
    );
    return;
  }

  setState(() {
    _salvando = true;
  });

  try {
    final advertencia = Advertencia(
      id: '',
      matriculaAluno: _alunoMatricula,
      data: data,
      justificativa: _justificativaSelecionada!,
      descricao: _descricaoController.text.trim(),
    );

    // 1. Salvar no banco de dados
    await DadosService.instancia.salvarAdvertencia(advertencia);

    // 2. Recuperar funcionário conectado
    final usuario =
        await DadosService.instancia.obterUsuarioConectado();

    final funcionarioNome =
        usuario?['nome']?.toString() ?? 'Não identificado';

    // 3. Gerar PDF
    try {
      await PdfService.gerarPdfAdvertencia(
        alunoNome: _alunoNome!,
        matricula: _alunoMatricula,
        curso: _alunoCurso,
        turma: _alunoTurma,
        data: data,
        justificativa: _justificativaSelecionada!,
        descricao: _descricaoController.text.trim(),
        funcionarioNome: funcionarioNome,
        tipoMedida: _tipoSelecionado!,
      );
    } catch (erroPdf) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Advertência salva, mas houve um erro ao gerar o PDF: $erroPdf',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advertência registrada!'),
        content: Text(
          'A advertência de $_alunoNome foi salva no banco de dados e o PDF foi gerado.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _limparFormulario();
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao registrar advertência: $e'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _salvando = false;
      });
    }
  }
}

  void _limparFormulario() {
  setState(() {
    _alunoNome = null;
    _alunoCurso = 'Selecione o aluno';
    _alunoTurma = 'Selecione o aluno';
    _alunoMatricula = 'Selecione o aluno';

   _alunosEmLote.clear();
_tipoSelecionado = null;
_justificativaSelecionada = null;
    

    _dataController.text =
        "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}";

    _descricaoController.clear();
  });
}
}