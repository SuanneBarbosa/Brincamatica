import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Models and Services
import '../../models/saved_row_models.dart'; // Ensure SavedIconData is imported
import '../../services/saved_row_service.dart';
import '../../services/icon_service.dart';
import '../../services/character_service.dart';

class SavedRowsScreen extends StatelessWidget {
  const SavedRowsScreen({super.key});

  // --- Helper Function to Get Icon Image Path (Mantida) ---
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

  // --- *** NOVO: Helper para gerar descrição semântica dos ícones *** ---
  String _generateIconSemantics(List<SavedIconData> icons) {
    if (icons.isEmpty) {
      return 'Nenhum ícone.';
    }
    // Mapeia tipos de ícones para nomes legíveis (ajuste conforme necessário)
    final iconNames = icons.map((iconData) {
      switch (iconData.type) {
        case "BaterPalma": return "Bater Palma";
        case "EstalarDedo": return "Estalar Dedo";
        case "BaterPeito": return "Bater Peito";
        case "BaterPerna": return "Bater Perna";
        case "Assobiar": return "Assobiar";
        case "BaterPe": return "Bater Pé";
        default: return iconData.type; // Fallback
      }
    }).toList();
    // Junta os nomes com vírgula
    return 'Ícones: ${iconNames.join(", ")}.';
  }


  // --- Helper para Diálogo de Confirmação (com Semantics adicionado) ---
  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        // AlertDialog já tem um papel semântico de 'dialog'
        return AlertDialog(
          // Título com Semantics (opcional, mas bom para marcar como header)
          title: Semantics(
            header: true, // Marca como cabeçalho dentro do diálogo
            child: Center(
              child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18.0)),
            ),
          ),
          // Conteúdo já é um Text, que fornece sua própria label
          content: Text(content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16.0)),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            // Botão Cancelar (Semantics já estava, mantido)
            Semantics(
              label: 'Cancelar', // Label explícito (embora TextButton faça isso)
              button: true,
              child: ElevatedButton( // Usando ElevatedButton para consistência
                onPressed: () => Navigator.of(context).pop(false), // Retorna false
                style: ElevatedButton.styleFrom( shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)) ),
                child: const Text("Cancelar", style: TextStyle(fontSize: 14.0)),
              ),
            ),
             const SizedBox(width: 10), // Espaçamento
            // Botão Confirmar (Semantics já estava, mantido)
            Semantics(
              label: 'Confirmar exclusão', // Label mais específico
              button: true,
              child: ElevatedButton(
                // Destaque visual para ação destrutiva (opcional)
                style: ElevatedButton.styleFrom( backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)) ),
                onPressed: () => Navigator.of(context).pop(true), // Retorna true
                child: const Text("Confirmar", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Helper para Diálogo de Seleção de Linha (com Semantics melhorado) ---
  Future<int?> _showTargetRowDialog(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int? selectedRow = 0; // Estado inicial

        return AlertDialog(
          // Título com Semantics
          title: Semantics(
            header: true,
            child: const Text('Aplicar em qual linha?', style: TextStyle(fontSize: 18.0), textAlign: TextAlign.center,),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          actionsAlignment: MainAxisAlignment.center,
          // Conteúdo com StatefulBuilder para gerenciar o estado do radio
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Centraliza a Row de opções
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Row ocupa o mínimo necessário
                      // Gera as opções de linha (0, 1, 2)
                      children: List<Widget>.generate(3, (int index) {
                        // *** Semantics Wrapper para cada opção de Rádio ***
                        return Semantics(
                          label: 'Selecionar Linha ${index + 1}', // Label claro
                          // Indica se esta opção está selecionada
                          value: selectedRow == index ? 'Selecionado' : 'Não selecionado',
                          checked: selectedRow == index, // Estado para leitores de tela
                          
                          // ExcludeSemantics para evitar que o InkWell/Radio interno seja focado separadamente
                          child: ExcludeSemantics(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              // InkWell para tornar toda a área clicável
                              child: InkWell(
                                onTap: () {
                                  setState(() { selectedRow = index; });
                                },
                                child: Column( // Coluna para Radio + Texto
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
          // Ações (Botões) do Diálogo
          actions: <Widget>[
            // Botão Cancelar (Semantics já estava ok)
             Semantics(
              label: 'Cancelar aplicação de linha', // Label mais específico
              button: true,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(null),
                style: ElevatedButton.styleFrom( shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)) ),
                child: const Text("Cancelar", style: TextStyle(fontSize: 14.0)),
              ),
            ),
             const SizedBox(width: 10), // Espaçamento
            // Botão Aplicar (Semantics já estava ok)
             Semantics(
              label: 'Aplicar na linha selecionada', // Label mais específico
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
    // Obtém services e controllers
    final savedRowService = Provider.of<SavedRowService>(context);
    final iconController = Provider.of<IconController>(context, listen: false);
    final characterController = Provider.of<CharacterController>(context, listen: false);
    // Obtém estilo atual do personagem para previews
    final typeParts = characterController.selectedCharacterType.split('_');
    final String currentGender = typeParts.isNotEmpty ? typeParts[0] : 'boy';
    final String currentTone = typeParts.length > 1 ? typeParts[1] : 'light';

    const double previewIconSize = 24.0;

    return Scaffold(
      appBar: AppBar(
        // Título com Semantics de Cabeçalho
        title: Semantics(
          header: true,
          child: const Text('Linhas Salvas'),
        ),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
         iconTheme: const IconThemeData(color: Colors.white), // Ícone de voltar branco
      ),
      body: Container(
         color: const Color.fromRGBO(220, 247, 255, 1.0), // Cor de fundo
         // Verifica se há linhas salvas
         child: savedRowService.savedRows.isEmpty
          // --- Estado Vazio ---
          ? const Center(
               // Semantics já estava bom aqui
               child: Text(
                'Nenhuma linha foi salva ainda.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                semanticsLabel: 'Nenhuma linha foi salva ainda.',
              ),
            )
          // --- Lista de Linhas Salvas ---
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
                            // Mostra a fileira de ícones apenas se houver ícones
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
                                             // Error builder como antes
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
                             else // Se não houver ícones (não deve acontecer se salvamento for prevenido)
                                const SizedBox.shrink(), // Não mostra nada
                          ],
                        ),
                        // Botões de Ação (Aplicar / Excluir)
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- Botão Aplicar ---
                            Tooltip( // Tooltip fornece a descrição padrão
                              message: 'Aplicar esta linha na tela principal',
                              child: Semantics( // Semantics explícito
                                label: 'Aplicar esta linha', // Label mais específico
                                button: true,
                                child: IconButton(
                                  icon: const Icon(Icons.playlist_add_check, color: Colors.green, semanticLabel: "Aplicar Linha"), // semanticLabel no Icon
                                  onPressed: () async {
                                    final int? targetRow = await _showTargetRowDialog(context);
                                    if (targetRow != null && context.mounted) { // Verifica context.mounted
                                       final double currentIconSize = characterController.currentIconSizeSetting;
                                       iconController.applySavedRow(targetRow, savedRow.icons, currentIconSize);
                                       ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('O conjunto "${savedRow.name}" foi aplicado na Linha ${targetRow + 1}.'), duration: const Duration(seconds: 2)),
                                       );
                                       // Tenta fechar a tela atual após aplicar
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
                            // --- Botão Excluir ---
                            Tooltip( // Tooltip fornece a descrição padrão
                              message: 'Excluir esta linha salva',
                              child: Semantics( // Semantics explícito
                                label: 'Excluir esta linha', // Label mais específico
                                button: true,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, semanticLabel: "Excluir Linha"), // semanticLabel no Icon
                                  onPressed: () async {
                                     final confirmed = await _showConfirmationDialog(context, 'Excluir Linha?', 'Tem certeza que deseja excluir a linha salva?');
                                     if (confirmed == true && context.mounted) { // Verifica context.mounted
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
                        // onTap: null, // Garante que o ListTile em si não seja clicável
                      
                    
                  ),
                );
              },
            ),
      ),
    );
  }
}