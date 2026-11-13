import 'package:flutter/material.dart';

class CustomTableCard extends StatelessWidget {
  final String title;
  final List<String> columns;
  final List<DataRow> rows;
  final VoidCallback? onTap;

  const CustomTableCard({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Força o Card a ocupar 100% da largura
      child: Card(
        elevation: 2,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, // Expande a área da tabela
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMaxHeight: 48,
                      columnSpacing: 40,
                      columns: columns
                          .map(
                            (coluna) => DataColumn(
                              label: Text(
                                coluna,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      rows: rows,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}