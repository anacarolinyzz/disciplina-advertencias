import 'package:flutter/material.dart';

class SecaoDadosAdvertencia extends StatelessWidget {
  final bool emLote;
  final TextEditingController dataController;
  final TextEditingController descricaoController;
  final String? justificativaSelecionada;
  final List<String> justificativas;
  final ValueChanged<String?> onJustificativaChanged;
  final String curso;
  final String turma;
  final String matricula;

  const SecaoDadosAdvertencia({
    super.key,
    required this.emLote,
    required this.dataController,
    required this.descricaoController,
    required this.justificativaSelecionada,
    required this.justificativas,
    required this.onJustificativaChanged,
    required this.curso,
    required this.turma,
    required this.matricula,
  });

  // Função para abrir o calendário nativo
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (dataEscolhida != null) {
      final dia = dataEscolhida.day.toString().padLeft(2, '0');
      final mes = dataEscolhida.month.toString().padLeft(2, '0');
      final ano = dataEscolhida.year;
      
      dataController.text = "$dia/$mes/$ano";
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações da advertência',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Data e Justificativa (Lado a lado no Desktop, Empilhados no Mobile)
            if (isMobile) ...[
              _buildCampoData(context),
              const SizedBox(height: 16),
              _buildCampoJustificativa(),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _buildCampoData(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCampoJustificativa()),
                ],
              ),
            ],

            const SizedBox(height: 16),
            const Text('Descrição da ocorrência', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: descricaoController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Descreva os detalhes da ocorrência...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // Informações do Aluno
            if (isMobile) ...[
              _buildInfoBox(context, 'Curso', emLote ? 'Múltiplos' : curso),
              const SizedBox(height: 8),
              _buildInfoBox(context, 'Turma', emLote ? 'Múltiplos' : turma),
              const SizedBox(height: 8),
              _buildInfoBox(context, 'Matrícula', emLote ? 'Múltiplas' : matricula),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _buildInfoBox(context, 'Curso', emLote ? 'Múltiplos' : curso)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoBox(context, 'Turma', emLote ? 'Múltiplos' : turma)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoBox(context, 'Matrícula', emLote ? 'Múltiplas' : matricula)),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  // Campo de Data com Calendário
  Widget _buildCampoData(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data da ocorrência', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: dataController,
          readOnly: true,
          onTap: () => _selecionarData(context),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selecionarData(context),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // Dropdown da Justificativa
  Widget _buildCampoJustificativa() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Justificativa Legal', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: justificativaSelecionada,
          hint: const Text('Selecione...'),
          isExpanded: true,
          items: justificativas.map((j) {
            return DropdownMenuItem(
              value: j,
              child: Text(j, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onJustificativaChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // Caixas Informativas (Curso, Turma, Matrícula)
  Widget _buildInfoBox(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
} 