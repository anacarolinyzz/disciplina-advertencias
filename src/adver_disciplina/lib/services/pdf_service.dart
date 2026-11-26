
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfService {
  // GERA O PDF E ABRE A TELA DE IMPRESSÃO
  static Future<void> gerarPdfAdvertencia({
    required String alunoNome,
    required String matricula,
    required String curso,
    required String turma,
    required DateTime data,
    required String justificativa,
    required String descricao,
    required String funcionarioNome,
    String tipoMedida = 'Advertência por escrito',
  }) async {
    final bytes = await gerarPdfBytes(
      alunoNome: alunoNome,
      matricula: matricula,
      curso: curso,
      turma: turma,
      data: data,
      justificativa: justificativa,
      descricao: descricao,
      funcionarioNome: funcionarioNome,
      tipoMedida: tipoMedida,
    );

    await Printing.layoutPdf(
      name: 'Medida_Disciplinar_$matricula.pdf',
      onLayout: (format) async => bytes,
    );
  }

  // GERA O PDF EM MEMÓRIA PARA O CADASTRO EM LOTE
  static Future<Uint8List> gerarPdfBytes({
    required String alunoNome,
    required String matricula,
    required String curso,
    required String turma,
    required DateTime data,
    required String justificativa,
    required String descricao,
    required String funcionarioNome,
    String tipoMedida = 'Advertência por escrito',
  }) async {
    final documento = await _criarDocumento(
      alunoNome: alunoNome,
      matricula: matricula,
      curso: curso,
      turma: turma,
      data: data,
      justificativa: justificativa,
      descricao: descricao,
      tipoMedida: tipoMedida,
    );

    return documento.save();
  }

  // MONTA O DOCUMENTO OFICIAL
  static Future<pw.Document> _criarDocumento({
    required String alunoNome,
    required String matricula,
    required String curso,
    required String turma,
    required DateTime data,
    required String justificativa,
    required String descricao,
    required String tipoMedida,
  }) async {
    final documento = pw.Document();
    final logo = await _carregarLogo();

    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';

    final titulo = _obterTitulo(tipoMedida);
    final dataPorExtenso = _formatarDataPorExtenso(data);

    documento.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 45, 40, 40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // CABEÇALHO INSTITUCIONAL
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Row(
                      children: [
                        pw.Image(
                          logo,
                          width: 55,
                          height: 75,
                          fit: pw.BoxFit.contain,
                        ),
                        pw.SizedBox(width: 7),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'INSTITUTO FEDERAL',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                'Piauí',
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                              pw.Text(
                                'Campus Paulistana',
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Instituto Federal de Educação, Ciência e',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.Text(
                          'Tecnologia do Piauí - Campus Paulistana',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.Text(
                          'Direção de Ensino',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.Text(
                          'Coordenação de Disciplina',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 45),

              // TÍTULO DINÂMICO
              pw.Center(
                child: pw.Text(
                  titulo,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 30),

              // DADOS DO ALUNO
              pw.Text(
                'Aluno(a): $alunoNome',
                style: const pw.TextStyle(fontSize: 11),
              ),

              pw.SizedBox(height: 22),

              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Curso: $curso',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Text(
                      'Turma: $turma',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 22),

              pw.Text(
                'Data da ocorrência: $dataFormatada',
                style: const pw.TextStyle(fontSize: 11),
              ),

              pw.SizedBox(height: 22),

              // JUSTIFICATIVA LEGAL
              pw.Text(
                'Justificativa legal: $justificativa',
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 10,
                  lineSpacing: 2,
                ),
              ),

              pw.SizedBox(height: 22),

              // DESCRIÇÃO
              pw.Text(
                'Descrição: $descricao',
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 10,
                  lineSpacing: 3,
                ),
              ),

             pw.SizedBox(height: 42),

          

              // ESPAÇO ENTRE A DESCRIÇÃO E A DATA
pw.SizedBox(height: 35),

// LOCAL E DATA
pw.Center(
  child: pw.Text(
    'Paulistana-PI, $dataPorExtenso',
    textAlign: pw.TextAlign.center,
    style: const pw.TextStyle(fontSize: 11),
  ),
),

pw.SizedBox(height: 35),

// ASSINATURA DA COORDENAÇÃO
_linhaAssinatura(
  'Coordenação de Curso/Chefe de Departamento/Direção de Ensino',
),

pw.SizedBox(height: 30),

// ASSINATURA DO ALUNO
_linhaAssinaturaAluno(
  nome: alunoNome,
  matricula: matricula,
),

pw.SizedBox(height: 30),

// ASSINATURA DO RESPONSÁVEL
_linhaAssinatura('Responsável pelo aluno'),
            ],
          );
        },
      ),
    );

    return documento;
  }

  // DEFINE O TÍTULO CONFORME A MODALIDADE
  static String _obterTitulo(String tipoMedida) {
    switch (tipoMedida.toLowerCase()) {
      case 'advertência oral':
        return 'TERMO DE ADVERTÊNCIA VERBAL';

      case 'advertência por escrito':
        return 'TERMO DE ADVERTÊNCIA POR ESCRITO';

      case 'suspensão':
        return 'TERMO DE SUSPENSÃO';

      default:
        return 'TERMO DE MEDIDA DISCIPLINAR';
    }
  }

  // FORMATA A DATA POR EXTENSO
  static String _formatarDataPorExtenso(DateTime data) {
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

    return '${data.day} de ${meses[data.month - 1]} de ${data.year}';
  }

  static Future<pw.ImageProvider> _carregarLogo() async {
    final logo = await rootBundle.load('assets/images/logo_ifpi.png');

    return pw.MemoryImage(logo.buffer.asUint8List());
  }

  // LINHA DE ASSINATURA SIMPLES
  static pw.Widget _linhaAssinatura(String texto) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Container(
            width: 290,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: PdfColors.black,
                  width: 0.8,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            texto,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  // LINHA DE ASSINATURA DO ALUNO COM NOME E MATRÍCULA
  static pw.Widget _linhaAssinaturaAluno({
    required String nome,
    required String matricula,
  }) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Container(
            width: 290,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: PdfColors.black,
                  width: 0.8,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            nome,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            'Matrícula: $matricula',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }
  
  
}
