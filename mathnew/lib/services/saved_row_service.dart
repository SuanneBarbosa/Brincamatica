import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_row_models.dart';
import 'icon_service.dart'; 


class SavedRowService extends ChangeNotifier {
  static const _savedRowsKey = 'saved_rows';
  List<SavedRow> _savedRows = [];

  List<SavedRow> get savedRows => _savedRows;

  SavedRowService() {
    loadSavedRows(); 
  }

  Future<void> loadSavedRows() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rowsJson = prefs.getString(_savedRowsKey);
      if (rowsJson != null && rowsJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(rowsJson);
        _savedRows = decodedList
            .map((item) => SavedRow.fromJson(item as Map<String, dynamic>))
            .toList();
      
      } else {
        _savedRows = [];
         debugPrint("No saved rows found or key is empty.");
      }
    } catch (e) {
      _savedRows = []; 
      debugPrint("Error loading saved rows: $e");
    }
    notifyListeners();
  }


  Future<void> _persistRows() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String rowsJson = jsonEncode(_savedRows.map((row) => row.toJson()).toList());
      await prefs.setString(_savedRowsKey, rowsJson);
      debugPrint("Persisted ${_savedRows.length} rows.");
    } catch (e) {
      debugPrint("Error persisting rows: $e");
    }
  }

 
  Future<void> saveRow(int rowIndex, List<IconModel> iconsInRow, String name) async {
  if (iconsInRow.isEmpty) {
    debugPrint("Attempted to save an empty row ($rowIndex). Aborting.");
    return; 
  }

  final String newId = 'row_${rowIndex}_${DateTime.now().millisecondsSinceEpoch}';
  final List<SavedIconData> savedIcons = iconsInRow.map((icon) =>
    SavedIconData(type: icon.type, colIndex: icon.colIndex)
  ).toList();

 
  final uniqueColIndices = <int>{};
  savedIcons.retainWhere((icon) => uniqueColIndices.add(icon.colIndex));

 
  String defaultName;
  if (name.isNotEmpty) {
    defaultName = name;
  } else {
   
    final now = DateTime.now();
    final String formattedDay = now.day.toString().padLeft(2, '0');
    final String formattedMonth = now.month.toString().padLeft(2, '0');
    final String formattedYear = now.year.toString();

   
    defaultName = 'Salvo na linha ${rowIndex + 1} em $formattedDay/$formattedMonth/$formattedYear';
  }
  


  final newSavedRow = SavedRow(
    id: newId,
    name: defaultName, // Usa o nome definido acima
    originalRowIndex: rowIndex,
    icons: savedIcons,
  );

  _savedRows.add(newSavedRow);
  await _persistRows();
  notifyListeners();
  // O debugPrint usará o nome final (fornecido ou padrão)
  debugPrint("Saved row '${newSavedRow.name}' (ID: $newId) from index $rowIndex with ${savedIcons.length} icons.");
}

  
  Future<void> deleteRow(String id) async {
    final initialLength = _savedRows.length;
    _savedRows.removeWhere((row) => row.id == id);
    if (_savedRows.length < initialLength) {
       await _persistRows();
       notifyListeners();
    } 
  }

  
  SavedRow? getSavedRowById(String id) {
      try {
          return _savedRows.firstWhere((row) => row.id == id);
      } catch (e) {
          return null; 
      }
  }
}