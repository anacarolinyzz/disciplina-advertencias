
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfService {
  // GERA O PDF E ABRE A TELA DE IMPRESSÃO (CADASTRO INDIVIDUAL)
  static Future<void> gerarPdfAdvertencia({
    required String alunoNome,
    required String matricula,
    required String curso,
    required String turma,
    required DateTime data,
    required String justificativa,
    required String descricao,
    required String funcionarioNome,
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
    );

    await Printing.layoutPdf(
      name: 'Advertencia_$matricula.pdf',
      onLayout: (format) async => bytes,
    );
  }

  // GERA O PDF EM MEMÓRIA, SEM ABRIR A TELA DE IMPRESSÃO (CADASTRO EM LOTE)
  static Future<Uint8List> gerarPdfBytes({
    required String alunoNome,
    required String matricula,
    required String curso,
    required String turma,
    required DateTime data,
    required String justificativa,
    required String descricao,
    required String funcionarioNome,
  }) async {
    final documento = await _criarDocumento(
      alunoNome: alunoNome,
      matricula: matricula,
      curso: curso,
      turma: turma,
      data: data,
      justificativa: justificativa,
      descricao: descricao,
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
  }) async {
    final documento = pw.Document();
    final logo = await _carregarLogo();

    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';

    documento.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 35, 40, 35),
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
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
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

              pw.SizedBox(height: 85),

              // TÍTULO
              pw.Center(
                child: pw.Text(
                  'TERMO DE ADVERTÊNCIA',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ),

              pw.SizedBox(height: 45),

              // DADOS DO ALUNO
              pw.Text(
                'Aluno(a): $alunoNome',
                style: const pw.TextStyle(fontSize: 11),
              ),

              pw.SizedBox(height: 35),

              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Curso: $curso',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Turma: $turma',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 35),

              pw.Text(
                'Data da ocorrência: $dataFormatada',
                style: const pw.TextStyle(fontSize: 11),
              ),

              pw.SizedBox(height: 35),

              pw.Text(
                'Justificativa legal: $justificativa',
                style: const pw.TextStyle(fontSize: 11),
              ),

              pw.SizedBox(height: 35),

              pw.Text(
                'Descrição: $descricao',
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 11,
                  lineSpacing: 3,
                ),
              ),

              pw.Spacer(),

              // LOCAL
              pw.Center(
                child: pw.Text(
                  'Paulistana-PI, ________________________________',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),

              pw.SizedBox(height: 75),

              // ASSINATURA COORDENAÇÃO
              _linhaAssinatura(
                'Coordenação de Curso/Chefe de Departamento/Direção de Ensino',
              ),

              pw.SizedBox(height: 65),

              // MATRÍCULA
              _linhaAssinatura('Matrícula:'),

              pw.SizedBox(height: 65),

              // RESPONSÁVEL
              _linhaAssinatura('Responsável pelo aluno'),
            ],
          );
        },
      ),
    );

    return documento;
  }

  static Future<pw.ImageProvider> _carregarLogo() async {
    final logo = await rootBundle.load('assets/images/logo_ifpi.png');

    return pw.MemoryImage(logo.buffer.asUint8List());
  }

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
}
