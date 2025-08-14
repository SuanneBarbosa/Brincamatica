class SavedIconData {
  final String type;
  final int colIndex;

  SavedIconData({
    required this.type,
    required this.colIndex,
  });

  
  Map<String, dynamic> toJson() => {
        'type': type,
        'colIndex': colIndex,
      };

  factory SavedIconData.fromJson(Map<String, dynamic> json) => SavedIconData(
        type: json['type'] as String,
        colIndex: json['colIndex'] as int,
      );
}

class SavedRow {
  final String id; 
  final String name; 
  final int originalRowIndex; 
  final List<SavedIconData> icons;

  SavedRow({
    required this.id,
    required this.name,
    required this.originalRowIndex,
    required this.icons,
  });

  
   Map<String, dynamic> toJson() => {
         'id': id,
         'name': name,
         'originalRowIndex': originalRowIndex,
         'icons': icons.map((icon) => icon.toJson()).toList(),
       };

   factory SavedRow.fromJson(Map<String, dynamic> json) => SavedRow(
         id: json['id'] as String,
         name: json['name'] as String? ?? 'Linha Salva', 
         originalRowIndex: json['originalRowIndex'] as int,
         icons: (json['icons'] as List<dynamic>)
             .map((iconJson) => SavedIconData.fromJson(iconJson as Map<String, dynamic>))
             .toList(),
       );
}