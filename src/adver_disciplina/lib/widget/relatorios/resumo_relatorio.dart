import 'package:flutter/material.dart';

class ResumoRelatorio extends StatelessWidget {
  final int totalAdvertencias;
  final int totalAlunosEnvolvidos;

  const ResumoRelatorio({
    super.key,
    required this.totalAdvertencias,
    required this.totalAlunosEnvolvidos,
  });

  Widget _itemResumo(String titulo, String valor) {
    return Builder(
      builder: (context) {
        return Container(
          width: 210,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _itemResumo(
          'Advertências encontradas',
          '$totalAdvertencias',
        ),
        _itemResumo(
          'Alunos envolvidos',
          '$totalAlunosEnvolvidos',
        ),
      ],
    );
  }
}
