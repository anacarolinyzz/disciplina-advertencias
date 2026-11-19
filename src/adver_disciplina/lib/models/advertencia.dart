
class Advertencia {
  final String id;
  final String matriculaAluno;
  final DateTime data;
  final String justificativa;
  final String descricao;

  const Advertencia({
    required this.id,
    required this.matriculaAluno,
    required this.data,
    required this.justificativa,
    required this.descricao,
  });

  factory Advertencia.fromJson(Map<String, dynamic> json) {
    return Advertencia(
      id: (json['idAdvertencia'] ?? json['id'] ?? '').toString(),
      matriculaAluno:
          (json['matriculaAluno'] ?? json['matricula_aluno'] ?? '')
              .toString(),
      data: DateTime.parse(
        (json['data_advertencia'] ?? json['data']).toString(),
      ),
      justificativa:
          (json['justificativaLegal'] ?? json['justificativa'] ?? '')
              .toString(),
      descricao: (json['descricao'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAdvertencia': id,
      'matriculaAluno': matriculaAluno,
      'data_advertencia': data.toIso8601String().split('T').first,
      'justificativaLegal': justificativa,
      'descricao': descricao,
    };
  }
}
