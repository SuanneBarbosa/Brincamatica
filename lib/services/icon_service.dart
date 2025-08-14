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
    bool layoutChanged = _horizontalPadding != horizontalPadding ||
        _verticalPadding != verticalPadding ||
        _rowHeight != rowHeight ||
        _colWidth != colWidth;

    _horizontalPadding = horizontalPadding;
    _verticalPadding = verticalPadding;
    _rowHeight = rowHeight;
    _colWidth = colWidth;

    if (layoutChanged) {
    
      for (int rowIndex in _rowIcons.keys) {
        List<IconModel> updatedIcons = [];
        for (IconModel oldIcon in _rowIcons[rowIndex]!) {
          final double newX =
              _horizontalPadding + (oldIcon.colIndex * _colWidth);
          final double newY = _verticalPadding +
              (oldIcon.rowIndex * _rowHeight) +
              (_rowHeight / 2) -
              (oldIcon.size / 2);
          final Offset newPosition = Offset(newX, newY);

          updatedIcons.add(IconModel(
            position: newPosition,
            type: oldIcon.type,
            semanticsLabel: oldIcon.semanticsLabel,
            size: oldIcon.size,
            rowIndex: oldIcon.rowIndex,
            colIndex: oldIcon.colIndex,
          ));
        }
        _rowIcons[rowIndex] = updatedIcons;
      }
      notifyListeners();
    }
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
      return;
    }

    final list = _rowIcons[rowIndex]!;
    final indexToReplace = list.indexWhere((icon) => icon.colIndex == colIndex);

    if (indexToReplace == -1) {
     
      return;
    }

    final double x = _horizontalPadding + (colIndex * _colWidth);
    final double y = _verticalPadding +
        (rowIndex * _rowHeight) +
        (_rowHeight / 2) -
        (newSize / 2);
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
      "BaterPe",
      "BaterPalma",
      "EstalarDedo",
      "BaterPerna",
      "BaterPeito",
      "Gritar",
      "EstalarLingua1",
      "EstalarLingua2",
      "Beijo",

    ];
    if (!validTypes.contains(type)) throw ArgumentError("Tipo inválido: $type");
    if (isRowFull(rowIndex)) {
      return;
    }

    final double x = _horizontalPadding + (colIndex * _colWidth);
    final double y = _verticalPadding +
        (rowIndex * _rowHeight) +
        (_rowHeight / 2) -
        (size / 2);
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

   
    notifyListeners();
  }

  void removeIcon(IconModel icon) {
    bool removed = false;
    _rowIcons[icon.rowIndex]?.remove(icon);
    removed = true;

    if (removed) {
     
      notifyListeners();
    }
  }

  void clearIcons() {
    for (final list in _rowIcons.values) {
      list.clear();
    }
  
    notifyListeners();
  }

  void checkAllIconsOffscreen(
      BuildContext context, double screenWidth, double screenHeight) {}

  void clearRow(int rowIndex) {
    if (_rowIcons.containsKey(rowIndex)) {
      _rowIcons[rowIndex]!.clear();
    
      notifyListeners();
    } 
  }

  String _getSemanticsLabelFromType(String type) {
    switch (type) {
      case "BaterPe":
        return "Bater Pe";
      case "Assobiar":
        return "Assobiar";
      case "BaterPalma":
        return "Bater Palma";
      case "EstalarDedo":
        return "Estalar Dedo";
      case "BaterPerna":
        return "Bater Perna";
      case "BaterPeito":
        return "Bater Peito";
      case "Gritar":
        return "Gritar";
      case "Estalar Lingua1":
        return "EstalarLingua1";
      case "EstalarLingua2":
        return "Estalar Lingua2";
      case "Beijo":
        return "Mandar Beijo";        
      default:
        return type;
    }
  }

  void applySavedRow(int targetRowIndex, List<SavedIconData> savedIcons,
      double currentIconSize) {
    if (targetRowIndex < 0 || targetRowIndex >= _rowIcons.length) {
     
      return;
    }

    clearRow(targetRowIndex);

    for (final savedIcon in savedIcons) {
      if (savedIcon.colIndex >= 0 && savedIcon.colIndex < _maxCols) {
        addIcon(
          rowIndex: targetRowIndex,
          colIndex: savedIcon.colIndex,
          type: savedIcon.type,
          semanticsLabel: _getSemanticsLabelFromType(savedIcon.type),
          size: currentIconSize,
        );
      } 
    }
    
  }
}
