class ScoreHistoryEntry {
  final int score;
  final int level;
  final DateTime date;

  ScoreHistoryEntry({
    required this.score,
    required this.level,
    required this.date,
  });

  
  Map<String, dynamic> toJson() => {
        'score': score,
        'level': level,
        'date': date.toIso8601String(), 
      };

 
  factory ScoreHistoryEntry.fromJson(Map<String, dynamic> json) => ScoreHistoryEntry(
        score: json['score'] as int,
        level: json['level'] as int,
        date: DateTime.parse(json['date'] as String), 
      );
}