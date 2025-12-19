import 'package:flutter/material.dart';

class SoundMemoryInstructionsScreen extends StatelessWidget {
  const SoundMemoryInstructionsScreen({super.key});

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
              title: 'Objetivo do Jogo',
              description:
                  'Seu objetivo é encontrar todos os pares de sons idênticos, fazendo com que eles desapareçam até que o tabuleiro esteja completamente limpo.',
              semanticsDescription:
                  'Encontre todos os pares de sons para limpar o tabuleiro.',
            ),
             _buildInstructionItem(
              title: 'Níveis de Dificuldade',
              description:
                  'O jogo possui dois níveis: Fácil, com 12 cartas que formam 6 pares, e Difícil, com 20 cartas que formam 10 pares. No nível difícil, novos sons, como estalar a língua, são adicionados. Você pode alterar a dificuldade no Menu Lateral.',
              semanticsDescription:
                  'Escolha entre Fácil ou Difícil no menu lateral. O modo difícil tem mais cartas e novos sons.',
            ),
            _buildInstructionItem(
              title: 'Como Iniciar',
              description:
                  'A partida começa com as cartas numeradas viradas para baixo. Para começar a jogar e ativar o cronômetro, toque no botão "Iniciar" localizado na barra superior.',
              semanticsDescription:
                  'Toque no botão Iniciar na barra superior para começar a partida e o cronômetro.',
            ),
             _buildInstructionItem(
              title: 'Cronômetro e Pares',
              description:
                  'Assim que o jogo começa, um cronômetro na barra superior marcará seu tempo. Ao lado, você pode acompanhar quantos pares já encontrou.',
              semanticsDescription:
                  'Acompanhe seu tempo e o número de pares encontrados na barra superior.',
            ),
            _buildInstructionItem(
              title: 'Como Jogar',
              description:
                  'Toque em uma carta para virá-la e ouvir seu som. Cada carta tem um número no verso para te ajudar a memorizar a posição. Em seguida, toque em outra carta para tentar encontrar o par.',
              semanticsDescription:
                  'Toque em uma carta, ouça o som, e use o número para memorizar. Depois, toque em outra para encontrar o par.',
            ),
            _buildInstructionItem(
              title: 'Encontrando um Par (Acerto)',
              description:
                  'Se as duas cartas viradas tiverem o mesmo som, um som de acerto tocará e o par desaparecerá da tela, limpando o tabuleiro.',
              semanticsDescription:
                  'Se os sons forem iguais, um som de acerto toca e as cartas somem.',
            ),
            _buildInstructionItem(
              title: 'Se as Cartas Não Forem um Par (Erro)',
              description:
                  'Se os sons forem diferentes, um som de erro tocará e, após um instante, as cartas voltarão a ficar viradas para baixo. Use os números para lembrar onde cada som está!',
              semanticsDescription:
                  'Se os sons forem diferentes, um som de erro toca e as cartas viram de volta para baixo.',
            ),
            _buildInstructionItem(
              title: 'Fim de Jogo',
              description:
                  'Quando todos os pares forem encontrados, o cronômetro para e uma mensagem de parabéns aparece, mostrando seu tempo final e o total de jogadas. Você pode então escolher "Jogar Novamente".',
              semanticsDescription:
                  'Ao encontrar todos os pares, o jogo acaba e você pode jogar novamente.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required String title,
    required String description,
    required String semanticsDescription,
  }) {
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