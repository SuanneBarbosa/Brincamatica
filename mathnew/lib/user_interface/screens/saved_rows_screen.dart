import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/saved_row_models.dart'; 
import '../../services/saved_row_service.dart';
import '../../services/icon_service.dart';
import '../../services/character_service.dart';

class SavedRowsScreen extends StatelessWidget {
  const SavedRowsScreen({super.key});

 
  String _getIconImagePath(String iconType, String gender, String tone) {
    String imagePath;
    String basePath = 'assets/images/icons/icon_';
    String toneSuffix = tone.isNotEmpty ? '_$tone' : '';
    String genderSuffix = gender.isNotEmpty ? '_$gender' : '';

    switch (iconType) {
      case "BaterPalma": imagePath = '${basePath}bater_palma$toneSuffix.png'; break;
      case "EstalarDedo": imagePath = '${basePath}estalar_dedo$toneSuffix.png'; break;
      case "BaterPeito":
      case "BaterPerna":
      case "Assobiar":
      case "BaterPe":
        String snakeCaseType = iconType.replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)?.toLowerCase()}').substring(1);
        imagePath = '$basePath$snakeCaseType$genderSuffix$toneSuffix.png';
        break;
      default: imagePath = 'assets/images/placeholder.png';
    }
    return imagePath;
  }


  String _generateIconSemantics(List<SavedIconData> icons) {
    if (icons.isEmpty) {
      return 'Nenhum ícone.';
    }
  
    final iconNames = icons.map((iconData) {
      switch (iconData.type) {
        case "BaterPalma": return "Bater Palma";
        case "EstalarDedo": return "Estalar Dedo";
        case "BaterPeito": return "Bater Peito";
        case "BaterPerna": return "Bater Perna";
        case "Assobiar": return "Assobiar";
        case "BaterPe": return "Bater Pé";
        default: return iconData.type; 
      }
    }).toList();
 
    return 'Ícones: ${iconNames.join(", ")}.';
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
      
        return AlertDialog(
         
          title: Semantics(
            header: true, 
            child: Center(
              child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18.0)),
            ),
          ),
         
          content: Text(content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16.0)),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
         
            Semantics(
              label: 'Cancelar', 
              button: true,
              child: ElevatedButton( 
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom( shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)) ),
                child: const Text("Cancelar", style: TextStyle(fontSize: 14.0)),
              ),
            ),
             const SizedBox(width: 10), 
           
            Semantics(
              label: 'Confirmar exclusão', 
              button: true,
              child: ElevatedButton(
               
                style: ElevatedButton.styleFrom( backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)) ),
                onPressed: () => Navigator.of(context).pop(true), 
                child: const Text("Confirmar", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  
  Future<int?> _showTargetRowDialog(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int? selectedRow = 0; 

        return AlertDialog(
         
          title: Semantics(
            header: true,
            child: const Text('Aplicar em qual linha?', style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center,),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          actionsAlignment: MainAxisAlignment.center,
       
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, 
                    
                      children: List<Widget>.generate(3, (int index) {
                    
                        return Semantics(
                          label: 'Selecionar Linha ${index + 1}', 
                        
                          value: selectedRow == index ? 'Selecionado' : 'Não selecionado',
                          checked: selectedRow == index, 
                          
                        
                          child: ExcludeSemantics(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                             
                              child: InkWell(
                                onTap: () {
                                  setState(() { selectedRow = index; });
                                },
                                child: Column( 
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Radio<int>(
                                      value: index,
                                      groupValue: selectedRow,
                                      onChanged: (int? value) {
                                        setState(() { selectedRow = value; });
                                      },
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text('Linha ${index + 1}', style: const TextStyle(fontSize: 12.0)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
         
          actions: <Widget>[
           
             Semantics(
              label: 'Cancelar aplicação de linha', 
              button: true,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(null),
                style: ElevatedButton.styleFrom( shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)) ),
                child: const Text("Cancelar", style: TextStyle(fontSize: 14.0)),
              ),
            ),
             const SizedBox(width: 10), 
           
             Semantics(
              label: 'Aplicar na linha selecionada', 
              button: true,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(selectedRow),
                style: ElevatedButton.styleFrom( shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), backgroundColor: Colors.green ), // Cor para ação positiva
                child: const Text("Aplicar", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
 
    final savedRowService = Provider.of<SavedRowService>(context);
    final iconController = Provider.of<IconController>(context, listen: false);
    final characterController = Provider.of<CharacterController>(context, listen: false);
  
    final typeParts = characterController.selectedCharacterType.split('_');
    final String currentGender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
    final String currentTone = typeParts.length > 1 ? typeParts[1] : 'light';

    const double previewIconSize = 24.0;

    return Scaffold(
      appBar: AppBar(
       
        title: Semantics(
          header: true,
          child: const Text('Linhas Salvas'),
        ),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
         iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Container(
         color: const Color.fromRGBO(220, 247, 255, 1.0), 
       
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
                final String iconSemantics = _generateIconSemantics(savedRow.icons);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                   title: Text(savedRow.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                   
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6.0),
                          
                            if (savedRow.icons.isNotEmpty)
                               SingleChildScrollView(
                                 scrollDirection: Axis.horizontal,
                                 child: Semantics(
                                   label: "Visualização dos ícones da linha salva. $iconSemantics", 
                                   image: false, 
                                   child: ExcludeSemantics(
                                     child: Row(
                                       children: savedRow.icons.map((iconData) {
                                         final String imagePath = _getIconImagePath(iconData.type, currentGender, currentTone);
                                         return Padding(
                                           padding: const EdgeInsets.only(right: 4.0),
                                           child: Image.asset(
                                             imagePath, height: previewIconSize, fit: BoxFit.contain,
                                           
                                             errorBuilder: (context, error, stackTrace) {
                                               return Container(
                                                 width: previewIconSize, height: previewIconSize, color: Colors.grey.shade300,
                                                 child: Icon(Icons.image_not_supported, size: previewIconSize * 0.6, color: Colors.grey.shade600),
                                               );
                                             },
                                           ),
                                         );
                                       }).toList(),
                                     ),
                                   ),
                                 ),
                               )
                             else 
                                const SizedBox.shrink(), 
                          ],
                        ),
                       
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           
                            Tooltip( 
                              message: 'Aplicar esta linha na tela principal',
                              child: Semantics( 
                                label: 'Aplicar esta linha', 
                                button: true,
                                child: IconButton(
                                  icon: const Icon(Icons.playlist_add_check, color: Colors.green, semanticLabel: "Aplicar Linha"), 
                                  onPressed: () async {
                                    final int? targetRow = await _showTargetRowDialog(context);
                                    if (targetRow != null && context.mounted) { 
                                       final double currentIconSize = characterController.currentIconSizeSetting;
                                       iconController.applySavedRow(targetRow, savedRow.icons, currentIconSize);
                                       ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('O conjunto "${savedRow.name}" foi aplicado na Linha ${targetRow + 1}.'), duration: const Duration(seconds: 2)),
                                       );
                                      
                                       if (Navigator.canPop(context)) {
                                         Navigator.pop(context);
                                       }
                                    }
                                  },
                                  splashRadius: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                           
                            Tooltip( 
                              message: 'Excluir esta linha salva',
                              child: Semantics( 
                                label: 'Excluir esta linha', 
                                button: true,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, semanticLabel: "Excluir Linha"), 
                                  onPressed: () async {
                                     final confirmed = await _showConfirmationDialog(context, 'Excluir Linha?', 'Tem certeza que deseja excluir a linha salva?');
                                     if (confirmed == true && context.mounted) { 
                                        await savedRowService.deleteRow(savedRow.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('O conjunto "${savedRow.name}" foi excluído.'), duration: const Duration(seconds: 2)),
                                        );
                                     }
                                  },
                                   splashRadius: 24,
                                ),
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