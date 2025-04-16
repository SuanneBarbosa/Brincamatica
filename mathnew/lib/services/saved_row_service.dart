import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_row_models.dart';
import 'icon_service.dart'; // To access IconModel
import 'character_service.dart'; // To access current icon size

class SavedRowService extends ChangeNotifier {
  static const _savedRowsKey = 'saved_rows';
  List<SavedRow> _savedRows = [];

  List<SavedRow> get savedRows => _savedRows;

  SavedRowService() {
    loadSavedRows(); // Load rows when service is initialized
  }

  // Load rows from SharedPreferences
  Future<void> loadSavedRows() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rowsJson = prefs.getString(_savedRowsKey);
      if (rowsJson != null && rowsJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(rowsJson);
        _savedRows = decodedList
            .map((item) => SavedRow.fromJson(item as Map<String, dynamic>))
            .toList();
         debugPrint("Loaded ${_savedRows.length} saved rows.");
      } else {
        _savedRows = [];
         debugPrint("No saved rows found or key is empty.");
      }
    } catch (e) {
      _savedRows = []; // Reset on error
      debugPrint("Error loading saved rows: $e");
    }
    notifyListeners();
  }

  // Save the current list of rows back to SharedPreferences
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

  // Save a specific row from the IconController
  Future<void> saveRow(int rowIndex, List<IconModel> iconsInRow, String name) async {
    if (iconsInRow.isEmpty) {
      debugPrint("Attempted to save an empty row ($rowIndex). Aborting.");
      return; // Don't save empty rows
    }

    final String newId = 'row_${rowIndex}_${DateTime.now().millisecondsSinceEpoch}';
    final List<SavedIconData> savedIcons = iconsInRow.map((icon) =>
      SavedIconData(type: icon.type, colIndex: icon.colIndex)
    ).toList();

    // Ensure unique column indices (safety check, should already be unique)
    final uniqueColIndices = <int>{};
    savedIcons.retainWhere((icon) => uniqueColIndices.add(icon.colIndex));


    final newSavedRow = SavedRow(
      id: newId,
      name: name.isNotEmpty ? name : 'Linha ${rowIndex + 1} - ${DateTime.now().toIso8601String().substring(0, 16)}', // Default name
      originalRowIndex: rowIndex,
      icons: savedIcons,
    );

    _savedRows.add(newSavedRow);
    await _persistRows();
    notifyListeners();
    debugPrint("Saved row '$name' (ID: $newId) from index $rowIndex with ${savedIcons.length} icons.");
  }

  // Delete a saved row by its ID
  Future<void> deleteRow(String id) async {
    final initialLength = _savedRows.length;
    _savedRows.removeWhere((row) => row.id == id);
    if (_savedRows.length < initialLength) {
       await _persistRows();
       notifyListeners();
       debugPrint("Deleted row with ID: $id");
    } else {
       debugPrint("Row with ID: $id not found for deletion.");
    }
  }

  // Get a specific saved row by ID (needed for applying)
  SavedRow? getSavedRowById(String id) {
      try {
          return _savedRows.firstWhere((row) => row.id == id);
      } catch (e) {
          return null; // Not found
      }
  }
}