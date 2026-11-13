import 'package:flutter/material.dart';

class SelecaoTipoRelatorio extends StatelessWidget {
  final String valor;
  final ValueChanged<String> aoAlterar;

  const SelecaoTipoRelatorio({
    super.key,
    required this.valor,
    required this.aoAlterar,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: valor,
      decoration: const InputDecoration(
        labelText: 'Tipo de relatório',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: 'Turma',
          child: Text('Por turma'),
        ),
        DropdownMenuItem(
          value: 'Curso',
          child: Text('Por curso'),
        ),
        DropdownMenuItem(
          value: 'Quantidade',
          child: Text('Por quantidade de advertências'),
        ),
        DropdownMenuItem(
          value: 'Data',
          child: Text('Por data'),
        ),
      ],
      onChanged: (novoValor) {
        if (novoValor != null) {
          aoAlterar(novoValor);
        }
      },
    );
  }
}
