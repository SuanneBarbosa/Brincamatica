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
                 
                  'Para mover o beija-flor, basta arrastá-lo pela tela na direção desejada (cima, baixo, esquerda ou direita) ou utilizar o Joystick que pode ser ativado no menu lateral.',
              semanticsDescription:
                
                  'Arraste o beija-flor na tela para movê-lo.',
            ),
             _buildInstructionItem(
              title: 'Ativando Joystick',
              description:
                 
                  'Para ativar ou desativar o Joystick abra o menu lateral e clique na opção Joystick. Com a opção do Joystick ativa você pode usar os botões para mover o beija-flor.',
              semanticsDescription:
                
                  'Ative ou desative o Joystick no menu lateral.',
            ),
            _buildInstructionItem(
              title: 'Tocando a Linha Atual',
              description:
                  'Posicione o beija-flor na linha que deseja ouvir. Toque no botão de Play na barra inferior para iniciar a reprodução dos ícones daquela linha, um após o outro. O botão mudará para Pause. Toque no botão Pause para interromper temporariamente a reprodução, e toque novamente em Play para continuar de onde parou.',
              semanticsDescription:
                  'Use o botão Play/Pause na barra inferior para tocar ou pausar a sequência de ícones da linha atual do beija-flor.',
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
                  
                  'Ajuste o tamanho dos ícones usando o controle deslizante "Tamanho do Ícone" no menu lateral.',
            ),
             _buildInstructionItem(
              title: 'Contador de Ícones',
              description:
                  
                  'Acesse o menu lateral e toque em "Contador de Ícones" para visualizar a quantidade total de ícones presentes na tela.',
              semanticsDescription:
                  
                  'Verifique a quantidade de ícones na tela usando "Contador de Ícones" no menu lateral.',
            ),
              _buildInstructionItem(
              title: 'Salvar Linha Atual',
              description:
                  
                  'No menu lateral, toque em "Salvar Linha Atual". Isso permitirá salvar a sequência de ícones da linha onde o beija-flor está posicionado.',
              semanticsDescription:
                  
                  'Salve a sequência da linha atual do beija-flor através da opção "Salvar Linha Atual" no menu lateral.',
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
          header: false,   
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