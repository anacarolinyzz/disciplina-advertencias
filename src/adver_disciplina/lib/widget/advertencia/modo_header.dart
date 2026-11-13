import 'package:flutter/material.dart';


class ModoHeader extends StatelessWidget {
  final bool emLote;
  final VoidCallback onToggleModo;

  const ModoHeader({
    super.key,
    required this.emLote,
    required this.onToggleModo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          emLote ? 'Nova Advertência (Em Lote)' : 'Nova Advertência',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        ElevatedButton.icon(
          onPressed: onToggleModo,
          icon: Icon(emLote ? Icons.person : Icons.groups),
          label: Text(emLote ? 'Modo Individual' : 'Gerar em Lote'),
          style: ElevatedButton.styleFrom(
            backgroundColor: emLote ? Colors.orange[800] : Colors.blueGrey[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}