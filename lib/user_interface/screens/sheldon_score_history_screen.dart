import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../../services/score_history_service.dart';

class ScoreHistoryScreen extends StatelessWidget {
  const ScoreHistoryScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, ScoreHistoryService historyService) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Semantics(
            header: true,
            child: const Center(
              child: Text(
                'Apagar histórico?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
          content: const Text(
            'Deseja apagar todo o histórico de pontuação? Esta ação não pode ser desfeita.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            Semantics(
              label: 'Cancelar',
              button: true,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Cancelar', style: TextStyle(fontSize: 14.0)),
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              label: 'Confirmar exclusão',
              button: true,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await historyService.clearHistory();
      SemanticsService.announce(
        "Histórico de pontuação apagado com sucesso.",
        TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyService = context.watch<ScoreHistoryService>();
    final hasScores = historyService.scores.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pontuação'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (hasScores)
            Semantics(
              label: 'Apagar todo o histórico',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Apagar histórico',
                onPressed: () => _confirmDelete(context, historyService),
              ),
            ),
        ],
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: Consumer<ScoreHistoryService>(
          builder: (context, historyService, child) {
            if (historyService.scores.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhuma pontuação salva ainda.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: historyService.scores.length,
              itemBuilder: (context, index) {
                final entry = historyService.scores[index];
                final formattedDate = DateFormat('dd/MM/yyyy – HH:mm').format(entry.date);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade700,
                      size: 40,
                    ),
                    title: Text(
                      'Pontuação: ${entry.score}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text('Nível alcançado: ${entry.level}'),
                    trailing: Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}