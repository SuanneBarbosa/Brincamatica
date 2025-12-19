import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/score_history_service.dart';

class ScoreHistoryScreen extends StatelessWidget {
  const ScoreHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pontuação'),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
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