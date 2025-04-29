import 'package:flutter/material.dart';
import 'dart:math';

class CharacterController extends ChangeNotifier {
  int _currentRowIndex = 0;
  int _currentColIndex = 0;
  final int _maxRows = 3;
  final int _maxCols = 10;
  String _selectedCharacterType = 'boy_light';
  double _screenWidth = 0;
  double _screenHeight = 0;
  double _rowHeight = 0;
  double _colWidth = 0;
  double _verticalPadding = 0.0;
  double _horizontalPadding = 0.0;
  final double _iconSpacing = 5.0;
  final double _characterVisualHeight = 70.0;
  final double _characterVisualWidth = 50.0;
  final String _beijaFlorImagePath = 'assets/images/personagem.png';
  double _xPosition = 0;
  double _yPosition = 0;
  double _currentIconSizeSetting = 50.0;
  double _maxAllowedIconSize = 50.0;
  bool _layoutInitialized = false;
  bool isHistoryMode = false;

  double get xPosition => _xPosition;
  double get yPosition => _yPosition;
  int get currentRowIndex => _currentRowIndex;
  int get currentColIndex => _currentColIndex;
  int get maxCols => _maxCols;
  int get maxRows => _maxRows;
  double get currentIconSizeSetting => _currentIconSizeSetting;
  double get maxAllowedIconSize => _maxAllowedIconSize;
  bool get isLayoutInitialized => _layoutInitialized;
  double get characterVisualHeight => _characterVisualHeight;
  double get characterVisualWidth => _characterVisualWidth;
  String get beijaFlorImagePath => _beijaFlorImagePath;
  String get selectedCharacterType => _selectedCharacterType;
  double get horizontalPadding => _horizontalPadding;
  double get verticalPadding => _verticalPadding;
  double get rowHeight => _rowHeight;
  double get colWidth => _colWidth;

  void setSelectedCharacter(String type) {
    const validTypes = ['boy_dark', 'boy_light', 'girl_dark', 'girl_light'];
    if (validTypes.contains(type)) {
      _selectedCharacterType = type;
      notifyListeners();
    }
  }

  void setIconSizeSetting(double newSize) {
    final clampedSize = newSize.clamp(30.0, _maxAllowedIconSize);
    if (_currentIconSizeSetting != clampedSize) {
      _currentIconSizeSetting = clampedSize;
      _updateLayoutParameters();
      notifyListeners();
    }
  }

  void setScreenSize(double width, double height) {
    if ((_screenWidth == width && _screenHeight == height) &&
        _layoutInitialized) {
      return;
    }
    _screenWidth = width;
    _screenHeight = height;
    _layoutInitialized = false;

    _updateLayoutParameters();

    _currentRowIndex = 0;
    _currentColIndex = 0;

    _updatePosition();
  }

  void _updateLayoutParameters() {
    if (_screenWidth <= 0 || _screenHeight <= 0 || _maxCols <= 0) {
      return;
    }

    const double gridTotalHeightPercentage = 0.60;
    final double gridTotalHeight = _screenHeight * gridTotalHeightPercentage;
    _rowHeight = gridTotalHeight / _maxRows;
    _verticalPadding = 0.0;

    double totalFixedSpacingWidth =
        (_maxCols > 1) ? (_maxCols - 1) * _iconSpacing : 0;
    double availableWidthForIconsOnly = _screenWidth - totalFixedSpacingWidth;
    double minTotalEdgePadding = 0.0;
    availableWidthForIconsOnly =
        max(0, availableWidthForIconsOnly - minTotalEdgePadding);
    _maxAllowedIconSize =
        max(30.0, (availableWidthForIconsOnly / _maxCols)).floorToDouble();
    _maxAllowedIconSize = max(30.0, _maxAllowedIconSize);

    if (!_layoutInitialized || _currentIconSizeSetting > _maxAllowedIconSize) {
      
      _currentIconSizeSetting = _maxAllowedIconSize;
    }
    _currentIconSizeSetting =
        _currentIconSizeSetting.clamp(30.0, _maxAllowedIconSize);

    final double maxIconHeightBasedOnRow = max(10.0, _rowHeight - 4.0);

    _currentIconSizeSetting =
        min(_currentIconSizeSetting, maxIconHeightBasedOnRow);
    _currentIconSizeSetting =
        _currentIconSizeSetting.clamp(30.0, _maxAllowedIconSize);

   
    _currentIconSizeSetting =
        min(_currentIconSizeSetting, maxIconHeightBasedOnRow);

    _currentIconSizeSetting =
        _currentIconSizeSetting.clamp(30.0, maxIconHeightBasedOnRow);
   

    double visualGridWidth =
        (_maxCols * _currentIconSizeSetting) + totalFixedSpacingWidth;
    _horizontalPadding = max(0.0, (_screenWidth - visualGridWidth) / 2.0);
    _colWidth = _currentIconSizeSetting + _iconSpacing;

    _updatePosition();
    _layoutInitialized = true;
    notifyListeners();
  }

  void _updatePosition() {
    if (!_layoutInitialized) return;

    _yPosition = _verticalPadding +
        (_currentRowIndex * _rowHeight) +
        (_rowHeight / 2) -
        (_characterVisualHeight / 2);

    double iconStartX = _horizontalPadding + (_currentColIndex * _colWidth);

    _xPosition = iconStartX;

    _xPosition = _xPosition.clamp(0, _screenWidth - _characterVisualWidth);
    _yPosition = _yPosition.clamp(0, _screenHeight - _characterVisualHeight);
  }

  void moveRight() {
    if (_currentColIndex < _maxCols - 1) {
      _currentColIndex++;
      _updatePosition();
      notifyListeners();
    } 
  }

  void moveLeft() {
    if (_currentColIndex > 0) {
      _currentColIndex--;
      _updatePosition();
      notifyListeners();
    } 
  }

  void moveUp() {
    if (_currentRowIndex > 0) {
      _currentRowIndex--;
      _updatePosition();
      notifyListeners();
    } 
  }

  void moveDown() {
    if (_currentRowIndex < _maxRows - 1) {
      _currentRowIndex++;
      _updatePosition();
      notifyListeners();
    } 
  }

  void moveToColumn(int targetColIndex) {
    targetColIndex = targetColIndex.clamp(0, _maxCols - 1);
    if (_currentColIndex != targetColIndex) {
      _currentColIndex = targetColIndex;
      _updatePosition();
      notifyListeners();
      
    }
  }

  void resetPosition() {
    _currentRowIndex = 0;
    _currentColIndex = 0;

    if (_layoutInitialized) {
      _updatePosition();
    }
    notifyListeners();
   
  }

  void moveToGridCell(int targetRow, int targetCol) {
    targetRow = targetRow.clamp(0, _maxRows - 1);
    targetCol = targetCol.clamp(0, _maxCols - 1);
    if (_currentRowIndex != targetRow || _currentColIndex != targetCol) {
      _currentRowIndex = targetRow;
      _currentColIndex = targetCol;
      _updatePosition();
      notifyListeners();
    }
  }
}
