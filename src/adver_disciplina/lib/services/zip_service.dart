
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'pdf_service.dart';

typedef AlunoMap = Map<String, String>;

class ZipService {
  static Future<List<String>> gerarEbaixarAdvertencias({
    required List<AlunoMap> alunos,
    required DateTime data,
    required String justificativa,
    required String descricao,
    required String tipoMedida,
  }) async {
    final arquivoZip = Archive();
    final List<String> pdfsComErro = [];

    for (final aluno in alunos) {
      final nome = aluno['nome'] ?? 'Aluno';
      final matricula = aluno['matricula'] ?? '';

      try {
        final pdfBytes = await PdfService.gerarPdfBytes(
          alunoNome: nome,
          matricula: matricula,
          curso: aluno['curso'] ?? '',
          turma: aluno['turma'] ?? '',
          data: data,
          justificativa: justificativa,
          descricao: descricao,
          funcionarioNome: '',
          tipoMedida: tipoMedida,
        );

        final nomeArquivo = _nomeSeguro('${matricula}_$nome');

        arquivoZip.addFile(
          ArchiveFile(
            '$nomeArquivo.pdf',
            pdfBytes.length,
            pdfBytes,
          ),
        );
      } catch (e) {
        pdfsComErro.add(nome);
      }
    }

    if (arquivoZip.isEmpty) {
      throw Exception('Não foi possível gerar nenhum PDF.');
    }

    final bytesZip = ZipEncoder().encode(arquivoZip);

    if (bytesZip.isEmpty) {
      throw Exception('Não foi possível criar o arquivo ZIP.');
    }

    _baixarArquivo(
      Uint8List.fromList(bytesZip),
      'Medidas_Disciplinares_${_dataParaNome(data)}.zip',
    );

    return pdfsComErro;
  }

  static String _nomeSeguro(String nome) {
    final nomeLimpo = nome
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

    return nomeLimpo.isEmpty ? 'medida_disciplinar' : nomeLimpo;
  }

  static String _dataParaNome(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '${data.year}-$mes-$dia';
  }

  static void _baixarArquivo(
    Uint8List bytes,
    String nomeArquivo,
  ) {
    final blob = html.Blob([bytes], 'application/zip');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final link = html.AnchorElement(href: url)
      ..download = nomeArquivo
      ..style.display = 'none';

    html.document.body!.children.add(link);
    link.click();
    link.remove();

    Future.delayed(const Duration(seconds: 1), () {
      html.Url.revokeObjectUrl(url);
    });
  }
}
