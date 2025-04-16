import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/saved_row_models.dart';
import '../../services/saved_row_service.dart';
import '../../services/icon_service.dart';
import '../../services/character_service.dart';

class SavedRowsScreen extends StatelessWidget {
  const SavedRowsScreen({Key? key}) : super(key: key);

  // --- Helper to show confirmation dialog ---
  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false), // Return false
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () => Navigator.of(context).pop(true), // Return true
            ),
          ],
        );
      },
    );
  }

  // --- Helper to show target row selection dialog ---
  Future<int?> _showTargetRowDialog(BuildContext context) {
     return showDialog<int>(
        context: context,
        builder: (BuildContext context) {
           int? selectedRow = 0; // Default to first row
           return AlertDialog(
              title: const Text('Aplicar em qual linha?'),
              content: StatefulBuilder( // Use StatefulBuilder for the radio buttons state
                 builder: (BuildContext context, StateSetter setState) {
                    return Column(
                       mainAxisSize: MainAxisSize.min,
                       children: List<Widget>.generate(3, (int index) { // Assuming 3 rows (0, 1, 2)
                          return RadioListTile<int>(
                             title: Text('Linha ${index + 1}'),
                             value: index,
                             groupValue: selectedRow,
                             onChanged: (int? value) {
                                setState(() {
                                   selectedRow = value;
                                });
                             },
                          );
                       }),
                    );
                 },
              ),
              actions: <Widget>[
                 TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.of(context).pop(null), // Return null for cancel
                 ),
                 TextButton(
                    child: const Text('Aplicar'),
                    onPressed: () => Navigator.of(context).pop(selectedRow), // Return selected row index
                 ),
              ],
           );
        },
     );
  }


  @override
  Widget build(BuildContext context) {
    // Access providers needed for actions
    final savedRowService = Provider.of<SavedRowService>(context);
    final iconController = Provider.of<IconController>(context, listen: false);
    final characterController = Provider.of<CharacterController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Linhas Salvas'),
        backgroundColor: Colors.blue,
         titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Container(
         color: const Color.fromRGBO(220, 247, 255, 1.0), // Match main screen background
         child: savedRowService.savedRows.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma linha foi salva ainda.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                semanticsLabel: 'Nenhuma linha foi salva ainda.',
              ),
            )
          : ListView.builder(
              itemCount: savedRowService.savedRows.length,
              itemBuilder: (context, index) {
                final savedRow = savedRowService.savedRows[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    title: Text(savedRow.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Originalmente da Linha ${savedRow.originalRowIndex + 1}, ${savedRow.icons.length} ícones'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- Apply Button ---
                        Tooltip(
                          message: 'Aplicar esta linha na tela principal',
                          child: IconButton(
                            icon: const Icon(Icons.playlist_add_check, color: Colors.green),
                            onPressed: () async {
                              final int? targetRow = await _showTargetRowDialog(context);
                              if (targetRow != null) {
                                 // Get current icon size from CharacterController
                                 final double currentIconSize = characterController.currentIconSizeSetting;

                                 // Call the apply method in IconController
                                 iconController.applySavedRow(targetRow, savedRow.icons, currentIconSize);

                                 ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                       content: Text('Linha "${savedRow.name}" aplicada na Linha ${targetRow + 1}.'),
                                       duration: const Duration(seconds: 2),
                                    ),
                                 );
                                 Navigator.pop(context); // Go back to main screen after applying
                              }
                            },
                            splashRadius: 24,
                          ),
                        ),
                        const SizedBox(width: 5),
                        // --- Delete Button ---
                        Tooltip(
                          message: 'Excluir esta linha salva',
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              final confirmed = await _showConfirmationDialog(
                                context,
                                'Excluir Linha?',
                                'Tem certeza que deseja excluir a linha salva "${savedRow.name}"?',
                              );
                              if (confirmed == true) {
                                await savedRowService.deleteRow(savedRow.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Linha "${savedRow.name}" excluída.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                // The list will rebuild automatically because SavedRowService notifies listeners
                              }
                            },
                             splashRadius: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}