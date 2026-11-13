
import 'package:adver/models/aluno.dart';
import 'package:adver/models/advertencia.dart';

class EstatisticasService {
  static Map<String, int> contarPorAluno(
    List<Advertencia> advertencias,
  ) {
    final Map<String, int> contagem = {};

    for (final advertencia in advertencias) {
      final matricula = advertencia.matriculaAluno;

      contagem[matricula] = (contagem[matricula] ?? 0) + 1;
    }

    return contagem;
  }

  static int totalAlunos(List<Aluno> alunos) {
    return alunos.length;
  }

  static int totalAdvertencias(
    List<Advertencia> advertencias,
  ) {
    return advertencias.length;
  }

  static int alunosComTresOuMais(
    List<Aluno> alunos,
    List<Advertencia> advertencias,
  ) {
    final contagem = contarPorAluno(advertencias);

    return alunos.where((aluno) {
      return (contagem[aluno.matricula] ?? 0) >= 3;
    }).length;
  }

  static int advertenciasNesteMes(
    List<Advertencia> advertencias,
  ) {
    final hoje = DateTime.now();

    return advertencias.where((advertencia) {
      return advertencia.data.year == hoje.year &&
          advertencia.data.month == hoje.month;
    }).length;
  }

  static List<Map<String, dynamic>> rankingAlunos(
    List<Aluno> alunos,
    List<Advertencia> advertencias,
  ) {
    final contagem = contarPorAluno(advertencias);

    final ranking = alunos.map((aluno) {
      return <String, dynamic>{
        'nome': aluno.nome,
        'matricula': aluno.matricula,
        'curso': aluno.curso,
        'turma': aluno.turma,
        'total': contagem[aluno.matricula] ?? 0,
      };
    }).where((item) {
      return (item['total'] as int) > 0;
    }).toList();

    ranking.sort((a, b) {
      return (b['total'] as int).compareTo(
        a['total'] as int,
      );
    });

    return ranking;
  }
}
