import 'package:flutter/material.dart';
import '../models/saved_row_models.dart';

class IconModel {
  final Offset position;
  final String type;
  final String semanticsLabel;
  final double size;
  final int rowIndex;
  final int colIndex;

  IconModel({
    required this.position,
    required this.type,
    required this.semanticsLabel,
    required this.size,
    required this.rowIndex,
    required this.colIndex,
  });

  Offset getWrappedPosition(double screenWidth, double screenHeight) {
    return position;
  }

  bool isPartiallyOffscreen(
      double screenWidth, double screenHeight, BuildContext context) {
    return false;
  } 

  List<String> getOffscreenEdges(
      double screenWidth, double screenHeight, BuildContext context) {
     return [];
  } 
}

class IconController extends ChangeNotifier {
  final Map<int, List<IconModel>> _rowIcons = {
    0: [],
    1: [],
    2: [],
  }; 
  final int _maxCols = 10;
  double _rowHeight = 0;
  double _colWidth = 0;
  double _verticalPadding = 0.0;
  double _horizontalPadding = 0.0;

  int get maxCols => _maxCols;

  void updateLayoutParameters({
    required double horizontalPadding,
    required double verticalPadding,
    required double rowHeight,
    required double colWidth,
  }) {
    _horizontalPadding = horizontalPadding;
    _verticalPadding = verticalPadding;
    _rowHeight = rowHeight;
    _colWidth = colWidth;
  }

  
  List<IconModel> get allIcons =>
      _rowIcons.values.expand((list) => list).toList();
  List<IconModel> getIconsForRow(int rowIndex) => _rowIcons[rowIndex] ?? [];
  int getNextColumnIndex(int rowIndex) => _rowIcons[rowIndex]?.length ?? 0;
  bool isRowFull(int rowIndex) => getNextColumnIndex(rowIndex) >= _maxCols;



  IconModel? getIconAt(int rowIndex, int colIndex) {
    
    if (!_rowIcons.containsKey(rowIndex)) {
      return null;
    }
   
    for (final icon in _rowIcons[rowIndex]!) {
      if (icon.colIndex == colIndex) {
        return icon;
      }
    }
    
    return null;
  }

  
  void replaceIconAt({
    required int rowIndex,
    required int colIndex,
    required String newType,
    required String newSemanticsLabel,
    required double newSize,
  }) {
     if (!_rowIcons.containsKey(rowIndex)) {
       debugPrint("Erro: Tentativa de substituir ícone em linha inexistente: $rowIndex");
       return;
     }

     
     final list = _rowIcons[rowIndex]!;
     final indexToReplace = list.indexWhere((icon) => icon.colIndex == colIndex);

     if (indexToReplace == -1) {
       debugPrint("Erro: Ícone não encontrado em ($rowIndex, $colIndex) para substituição.");
       return;
     }

     
     final double x = _horizontalPadding + (colIndex * _colWidth);
     final double y = _verticalPadding + (rowIndex * _rowHeight) + (_rowHeight / 2) - (newSize / 2);
     final Offset newPosition = Offset(x, y);

     
     final newIcon = IconModel(
       position: newPosition,
       type: newType,
       semanticsLabel: newSemanticsLabel,
       size: newSize,
       rowIndex: rowIndex,
       colIndex: colIndex,
     );

     
     list[indexToReplace] = newIcon;

     debugPrint("Replaced icon at Row $rowIndex, Col $colIndex with '$newType'. Position: $newPosition, Size: $newSize");
     notifyListeners(); 
  }

  void addIcon({
    required int rowIndex,
    required int colIndex,
    required String type,
    required String semanticsLabel,
    required double size,
  }) {
    const validTypes = [
      "Assobiar",
      "BaterPalma",
      "BaterPe",
      "EstalarDedo",
      "BaterPerna",
      "BaterPeito"
    ];
    if (!validTypes.contains(type)) throw ArgumentError("Tipo inválido: $type");
     if (isRowFull(rowIndex)) {
       debugPrint("Row $rowIndex full. Cannot add sequentially."); 
      
       return;
     }

    final double x = _horizontalPadding + (colIndex * _colWidth); 
    final double y = _verticalPadding + (rowIndex * _rowHeight) + (_rowHeight / 2) - (size / 2);
    final Offset position = Offset(x, y);

    final newIcon = IconModel(
      position: position,
      type: type,
      semanticsLabel: semanticsLabel,
      size: size,
      rowIndex: rowIndex,
      colIndex: colIndex, 
    );

    _rowIcons.putIfAbsent(rowIndex, () => []);
    _rowIcons[rowIndex]?.add(newIcon); 

    debugPrint("Added icon SEQUENTIALLY '$type' at Row $rowIndex, Col $colIndex. Position: $position, Size: $size");
    notifyListeners();
  }

  void removeIcon(IconModel icon) {
    bool removed = false;
    _rowIcons[icon.rowIndex]?.remove(icon);
    removed = true;

    if (removed) {
      debugPrint("Removed icon '${icon.type}' from row ${icon.rowIndex}");
      notifyListeners();
    }
  }

  void clearIcons() {
    for (final list in _rowIcons.values) {
      list.clear();
    }
    debugPrint("All icons cleared.");
    notifyListeners();
  }

  void checkAllIconsOffscreen(
      BuildContext context, double screenWidth, double screenHeight) {}

       void clearRow(int rowIndex) {
    if (_rowIcons.containsKey(rowIndex)) {
      final int count = _rowIcons[rowIndex]!.length;
      _rowIcons[rowIndex]!.clear();
      debugPrint("Cleared $count icons from row $rowIndex.");
      notifyListeners();
    } else {
       debugPrint("Attempted to clear non-existent row $rowIndex.");
    }
  }
  // Helper to get a simple label from type (you might already have this logic elsewhere)
 String _getSemanticsLabelFromType(String type) {
    // Add more cases as needed or use a map lookup
    switch (type) {
      case "Assobiar": return "Assobiar";
      case "BaterPalma": return "Bater Palma";
      case "BaterPe": return "Bater Pé";
      case "EstalarDedo": return "Estalar Dedo";
      case "BaterPerna": return "Bater Perna";
      case "BaterPeito": return "Bater Peito";
      default: return type; // Fallback
    }
  }

  // Method to apply a saved row's icons
  void applySavedRow(int targetRowIndex, List<SavedIconData> savedIcons, double currentIconSize) {
    if (targetRowIndex < 0 || targetRowIndex >= _rowIcons.length) {
       debugPrint("Error: Invalid target row index $targetRowIndex for applying saved row.");
       return;
    }

    // 1. Clear the target row first
    clearRow(targetRowIndex);

    // 2. Add icons from the saved data
    for (final savedIcon in savedIcons) {
       if (savedIcon.colIndex >= 0 && savedIcon.colIndex < _maxCols) {
          // Use the existing addIcon logic, ensuring it places at the correct colIndex
          addIcon(
             rowIndex: targetRowIndex,
             colIndex: savedIcon.colIndex, // Use the saved column index
             type: savedIcon.type,
             semanticsLabel: _getSemanticsLabelFromType(savedIcon.type), // Regenerate label
             size: currentIconSize, // Use the current global size setting
          );
       } else {
           debugPrint("Skipping saved icon '${savedIcon.type}' at invalid column index ${savedIcon.colIndex}");
       }
    }
     debugPrint("Applied ${savedIcons.length} icons to row $targetRowIndex.");
     // notifyListeners() is called within addIcon
}}
