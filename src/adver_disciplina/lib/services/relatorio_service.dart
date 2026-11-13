import 'package:adver/models/aluno.dart';
import 'package:adver/models/advertencia.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RelatorioService {
  RelatorioService._();

  static Future<void> gerarPdf({
    required List<Advertencia> advertencias,
    required Map<String, Aluno> alunosPorMatricula,
    required Map<String, int> contagemPorAluno,
    required String tipoRelatorio,
    required String cursoSelecionado,
    required String turmaSelecionada,
    required int quantidadeMinima,
    required String periodo,
    required String Function(DateTime) formatarData,
  }) async {
    final pdf = pw.Document();
    final dataEmissao = formatarData(DateTime.now());

    String titulo = 'Relatório por $tipoRelatorio';

    if (tipoRelatorio == 'Quantidade') {
      titulo += ' de advertências';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ADVER - Sistema de Gestão',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                titulo,
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Divider(),
            ],
          );
        },
        build: (context) {
          return [
            pw.Text('Data de emissão: $dataEmissao'),
            pw.SizedBox(height: 5),
            pw.Text('Período: $periodo'),
            pw.Text(
              'Curso: $cursoSelecionado | Turma: $turmaSelecionada',
            ),
            if (tipoRelatorio == 'Quantidade')
              pw.Text('Quantidade mínima: $quantidadeMinima'),
            pw.SizedBox(height: 15),
            pw.Text(
              'Total de advertências: ${advertencias.length}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: [
                'Data',
                'Aluno',
                'Curso',
                'Turma',
                'Justificativa',
                'Quantidade',
              ],
              data: advertencias.map((advertencia) {
                final aluno =
                    alunosPorMatricula[advertencia.matriculaAluno];

                final quantidade =
                    contagemPorAluno[advertencia.matriculaAluno] ?? 0;

                return [
                  formatarData(advertencia.data),
                  aluno?.nome ?? 'Aluno não encontrado',
                  aluno?.curso ?? '-',
                  aluno?.turma ?? '-',
                  advertencia.justificativa,
                  quantidade.toString(),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(6),
              border: pw.TableBorder.all(
                color: PdfColors.grey400,
                width: 0.5,
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      format: PdfPageFormat.a4.landscape,
    );
  }
}
