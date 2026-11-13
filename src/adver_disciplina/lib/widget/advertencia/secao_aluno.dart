
import 'package:flutter/material.dart';

typedef AlunoMap = Map<String, String>;

class SecaoAluno extends StatelessWidget {
  final bool emLote;
  final String? alunoNome;
  final List<String> alunosEmLote;
  final List<AlunoMap> listaAlunosCadastrados;
  final Function(AlunoMap) onAlunoSelecionado;
  final Function(String) onRemoverAlunoLote;
  
  const SecaoAluno({
    super.key,
    required this.emLote,
    this.alunoNome,
    required this.alunosEmLote,
    required this.listaAlunosCadastrados,
    required this.onAlunoSelecionado,
    required this.onRemoverAlunoLote,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emLote ? 'Alunos Selecionados (Lote)' : 'Dados do aluno',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            return Autocomplete<AlunoMap>(
              displayStringForOption: (option) =>
                  option['nome'] ?? '',

              optionsBuilder: (TextEditingValue value) {
                final pesquisa = value.text.trim().toLowerCase();

                if (pesquisa.isEmpty) {
                  return const Iterable<AlunoMap>.empty();
                }

                return listaAlunosCadastrados.where((aluno) {
                  final nome =
                      (aluno['nome'] ?? '').toLowerCase();

                  final matricula =
                      (aluno['matricula'] ?? '').toLowerCase();

                  return nome.contains(pesquisa) ||
                      matricula.contains(pesquisa);
                });
              },

              onSelected: (AlunoMap selecao) {
                onAlunoSelecionado(selecao);
              },

              fieldViewBuilder: (
                context,
                controller,
                focusNode,
                onEditingComplete,
              ) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: InputDecoration(
                    hintText: emLote
                        ? 'Digite para buscar e adicionar alunos ao lote...'
                        : 'Digite o nome ou matrícula do aluno...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                );
              },

              optionsViewBuilder: (
                context,
                onSelected,
                options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 8,
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),

                      // CORREÇÃO: limita a altura da lista
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 250,
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option =
                                options.elementAt(index);

                            return ListTile(
                              leading: const Icon(
                                Icons.person_outline,
                              ),
                              title: Text(
                                option['nome'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Turma: ${option['turma']} | '
                                'Matrícula: ${option['matricula']}',
                              ),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(height: 16),

        if (!emLote) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alunoNome != null
                        ? 'Aluno selecionado: $alunoNome'
                        : 'Nenhum aluno selecionado',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: alunoNome != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: alunosEmLote.map((aluno) {
              return Chip(
                label: Text(aluno),
                deleteIcon: const Icon(
                  Icons.close,
                  size: 18,
                ),
                onDeleted: () => onRemoverAlunoLote(aluno),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
