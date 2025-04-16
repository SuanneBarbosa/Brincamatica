import 'package:flutter/foundation.dart';

// Represents a single icon within a saved row
class SavedIconData {
  final String type;
  final int colIndex;

  SavedIconData({
    required this.type,
    required this.colIndex,
  });

  // For JSON serialization/deserialization
  Map<String, dynamic> toJson() => {
        'type': type,
        'colIndex': colIndex,
      };

  factory SavedIconData.fromJson(Map<String, dynamic> json) => SavedIconData(
        type: json['type'] as String,
        colIndex: json['colIndex'] as int,
      );
}

// Represents a complete saved row
class SavedRow {
  final String id; // Unique identifier (e.g., timestamp)
  final String name; // User-defined name
  final int originalRowIndex; // Which row it was saved from (0, 1, or 2)
  final List<SavedIconData> icons;

  SavedRow({
    required this.id,
    required this.name,
    required this.originalRowIndex,
    required this.icons,
  });

   // For JSON serialization/deserialization
   Map<String, dynamic> toJson() => {
         'id': id,
         'name': name,
         'originalRowIndex': originalRowIndex,
         'icons': icons.map((icon) => icon.toJson()).toList(),
       };

   factory SavedRow.fromJson(Map<String, dynamic> json) => SavedRow(
         id: json['id'] as String,
         name: json['name'] as String? ?? 'Linha Salva', // Default name if missing
         originalRowIndex: json['originalRowIndex'] as int,
         icons: (json['icons'] as List<dynamic>)
             .map((iconJson) => SavedIconData.fromJson(iconJson as Map<String, dynamic>))
             .toList(),
       );
}