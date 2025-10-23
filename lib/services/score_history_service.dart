import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/score_history_model.dart';

class ScoreHistoryService extends ChangeNotifier {
  static const _historyKey = 'score_history';
  List<ScoreHistoryEntry> _scores = [];

  List<ScoreHistoryEntry> get scores => _scores;

  ScoreHistoryService() {
    loadHistory();
  }

 
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_historyKey);
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(historyJson);
        _scores = decodedList
            .map((item) => ScoreHistoryEntry.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        _scores = [];
      }
    } catch (e) {
      _scores = [];
      debugPrint("Erro ao carregar histórico de pontuação: $e");
    }
    notifyListeners();
  }

  
  Future<void> _persistHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = jsonEncode(_scores.map((entry) => entry.toJson()).toList());
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      debugPrint("Erro ao salvar histórico de pontuação: $e");
    }
  }

  
  Future<void> addScoreEntry(int score, int level) async {
    final newEntry = ScoreHistoryEntry(
      score: score,
      level: level,
      date: DateTime.now(),
    );

    
    _scores.insert(0, newEntry);
    
    await _persistHistory();
    notifyListeners();
    debugPrint("Nova pontuação salva: ${newEntry.score} no nível ${newEntry.level}");
  }
}