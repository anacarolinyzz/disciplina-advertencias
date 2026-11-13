import 'package:flutter/material.dart';

class FiltrosRelatorio extends StatelessWidget {
  final String cursoSelecionado;
  final String turmaSelecionada;
  final List<String> cursos;
  final List<String> turmas;
  final String textoPeriodo;
  final String tipoRelatorio;
  final int quantidadeMinima;

  final ValueChanged<String?> aoAlterarCurso;
  final ValueChanged<String?> aoAlterarTurma;
  final VoidCallback aoSelecionarPeriodo;
  final ValueChanged<int?> aoAlterarQuantidade;
  final VoidCallback aoLimpar;

  const FiltrosRelatorio({
    super.key,
    required this.cursoSelecionado,
    required this.turmaSelecionada,
    required this.cursos,
    required this.turmas,
    required this.textoPeriodo,
    required this.tipoRelatorio,
    required this.quantidadeMinima,
    required this.aoAlterarCurso,
    required this.aoAlterarTurma,
    required this.aoSelecionarPeriodo,
    required this.aoAlterarQuantidade,
    required this.aoLimpar,
  });

  Widget _filtroDropdown({
    required String titulo,
    required String valor,
    required List<String> opcoes,
    required ValueChanged<String?> aoAlterar,
  }) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        value: valor,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: titulo,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        items: opcoes.map((opcao) {
          return DropdownMenuItem(
            value: opcao,
            child: Text(opcao, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: aoAlterar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _filtroDropdown(
          titulo: 'Curso',
          valor: cursoSelecionado,
          opcoes: ['Todos', ...cursos],
          aoAlterar: aoAlterarCurso,
        ),
        _filtroDropdown(
          titulo: 'Turma',
          valor: turmaSelecionada,
          opcoes: ['Todas', ...turmas],
          aoAlterar: aoAlterarTurma,
        ),
        OutlinedButton.icon(
          onPressed: aoSelecionarPeriodo,
          icon: const Icon(Icons.calendar_month),
          label: Text(textoPeriodo),
        ),
        if (tipoRelatorio == 'Quantidade')
          SizedBox(
            width: 190,
            child: DropdownButtonFormField<int>(
              value: quantidadeMinima,
              decoration: const InputDecoration(
                labelText: 'Mínimo de advertências',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 ou mais')),
                DropdownMenuItem(value: 2, child: Text('2 ou mais')),
                DropdownMenuItem(value: 3, child: Text('3 ou mais')),
              ],
              onChanged: aoAlterarQuantidade,
            ),
          ),
        TextButton.icon(
          onPressed: aoLimpar,
          icon: const Icon(Icons.filter_alt_off),
          label: const Text('Limpar filtros'),
        ),
      ],
    );
  }
}
