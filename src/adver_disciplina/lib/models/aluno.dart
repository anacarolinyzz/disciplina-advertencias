
class Aluno {
  final String matricula;
  final String nome;
  final String curso;
  final String turma;
  final int ativo;
  final int quantidadeAdvertencias;
  final int? idTurma;
  final int? idCurso;
  final int? anoLetivo;

  const Aluno({
    required this.matricula,
    required this.nome,
    required this.curso,
    required this.turma,
    this.ativo = 1,
    this.quantidadeAdvertencias = 0,
    this.idTurma,
    this.idCurso,
    this.anoLetivo,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      matricula: json['matricula'].toString(),
      nome: json['nome'].toString(),
      curso: json['curso']?.toString() ?? '',
      turma: json['turma']?.toString() ?? '',
      ativo: int.tryParse(json['ativo'].toString()) ?? 1,
      quantidadeAdvertencias:
          int.tryParse(json['quantidadeAdvertencias'].toString()) ?? 0,
      idTurma: json['idTurma'],
      idCurso: json['idCurso'],
      anoLetivo: json['anoLetivo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matricula': matricula,
      'nome': nome,
      'curso': curso,
      'turma': turma,
      'ativo': ativo,
      'quantidadeAdvertencias': quantidadeAdvertencias,
      'idTurma': idTurma,
      'idCurso': idCurso,
      'anoLetivo': anoLetivo,
    };
  }
}
