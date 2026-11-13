import 'package:flutter/material.dart';

class TabelaRelatorio extends StatelessWidget {
  final List<DataRow> linhas;
  final List<DataColumn> colunas;

  const TabelaRelatorio({
    super.key,
    required this.linhas,
    required this.colunas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado do relatório',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (linhas.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Nenhum registro encontrado para os filtros.'),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: colunas,
                  rows: linhas,
                  headingRowHeight: 48,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 64,
                  columnSpacing: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
