class Aluno {
  final String matricula;
  final String nome;
  final String curso;
  final String turma;

  const Aluno({
    required this.matricula,
    required this.nome,
    required this.curso,
    required this.turma,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      matricula: json['matricula'].toString(),
      nome: json['nome'].toString(),
      curso: json['curso'].toString(),
      turma: json['turma'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matricula': matricula,
      'nome': nome,
      'curso': curso,
      'turma': turma,
    };
  }
}