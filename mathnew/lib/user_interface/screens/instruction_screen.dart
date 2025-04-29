import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instruções de Uso"),
        backgroundColor: Colors.blue, 
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20), 
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: ListView(
          children: [
           _buildInstructionItem(
              title: 'Movimentando o beija-flor',
              description:
                 
                  'Para mover o beija-flor, basta arrastá-lo pela tela na direção desejada (cima, baixo, esquerda ou direita).',
              semanticsDescription:
                
                  'Arraste o beija-flor na tela para movê-lo.',
            ),
           _buildInstructionItem(
              title: 'Adicionando Ícones',
              description:
                 
                  'Toque nos botões de ação, localizados na barra inferior, para adicionar os ícones correspondentes na posição atual do beija-flor.',
              semanticsDescription:
                  
                  'Adicione ícones tocando nos botões de ação na parte inferior da tela.',
            ),
           _buildInstructionItem(
              title: 'Removendo um Ícone', 
              description:
                 
                  'Para remover um ícone específico, toque sobre ele na tela. Uma caixa de diálogo de confirmação será exibida antes da remoção.',
              semanticsDescription:
                
                  'Toque sobre um ícone para removê-lo.',
            ),
            _buildInstructionItem(
              title: 'Limpando a Tela',
              description:

                  'Abra o menu lateral (ícone no canto superior esquerdo) e toque na opção "Limpar Tela" para remover todos os ícones da grade.',
              semanticsDescription:
                    
                  'Use "Limpar Tela" no menu lateral para apagar todos os ícones.',
            ),
           _buildInstructionItem(
              title: 'Ajustando o Tamanho dos Ícones',  
              description:
                  
                  'No menu lateral, utilize o controle deslizante "Tamanho do Ícone" para definir o tamanho dos próximos ícones a serem adicionados. Atenção: alterar o tamanho também removerá todos os ícones atuais da tela.',
              semanticsDescription:
                  
                  'Ajuste o tamanho dos ícones usando o controle no menu lateral. Isso limpará a tela.',
            ),
             _buildInstructionItem(
              title: 'Contador de Ícones',
              description:
                  
                  'Acesse o menu lateral e toque em "Contador de Ícones" para visualizar rapidamente a quantidade total de ícones presentes na tela.',
              semanticsDescription:
                  
                  'Verifique a quantidade de ícones na tela usando "Contador de Ícones" no menu.',
            ),
              _buildInstructionItem(
              title: 'Salvar Linha Atual',
              description:
                  
                  'No menu lateral, toque em "Salvar Linha Atual". Isso permitirá salvar a sequência de ícones da linha onde o beija-flor está posicionado. Você precisará digitar um nome para a linha e confirmar para salvá-la.',
              semanticsDescription:
                  
                  'Salve a sequência da linha atual do beija-flor através da opção no menu lateral.',
            ),
             _buildInstructionItem(
              title: 'Gerenciar Linhas Salvas', 
              description:
                  
                  'Abra o menu lateral e toque em "Linhas Salvas" para ver suas sequências guardadas. Para usar (aplicar) uma linha salva, toque no ícone verde ao lado dela e escolha em qual linha da tela principal (1, 2 ou 3) deseja inseri-la. Para apagar permanentemente uma linha salva, toque no ícone vermelho de lixeira.',
              semanticsDescription:
                  
                  'Visualize, aplique ou exclua sequências de ícones salvas na opção "Linhas Salvas" do menu.',
            ),

          ],
        ),
      ),
    );
  }

    
  Widget _buildInstructionItem(
      {required String title,
      required String description,
      required String semanticsDescription}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          
        Semantics(
          label: title,   
          header: true,   
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blueAccent, 
            ),
          ),
        ),
        const SizedBox(height: 8),  
          
        Semantics(
          label: semanticsDescription,  
          child: Text(
            description,
            textAlign: TextAlign.justify,   
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,  
              height: 1.3,  
            ),
          ),
        ),
          
        const Divider(
          thickness: 1, 
          height: 30,   
          color: Colors.black12,  
        ),
      ],
    );
  }
}