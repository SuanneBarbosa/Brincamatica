import 'package:flutter/material.dart';

class MemoryGameInstructionsScreen extends StatelessWidget {
  const MemoryGameInstructionsScreen({super.key});

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
              title: 'Objetivo do jogo',
              description:
                  'Observe a sequência de sons e reproduza na mesma ordem tocando os botões correspondentes. A cada nível, a sequência fica mais longa e a velocidade pode aumentar.',
              semanticsDescription:
                  'Seu objetivo é repetir a sequência de sons na ordem correta.',
            ),
            _buildInstructionItem(
              title: 'Como iniciar',
              description:
                  'Na barra superior, toque no botão “Iniciar”. O jogo mostrará a primeira sequência. Ao final, será a sua vez.',
              semanticsDescription:
                  'Toque no botão Iniciar para começar a partida.',
            ),
            _buildInstructionItem(
              title: 'Durante a exibição da sequência',
              description:
                  'Enquanto aparecer “Observe a sequência...”, os botões ficam desativados. Fique atento à luz/realce dos cartões e aos sons correspondentes.',
              semanticsDescription:
                  'Enquanto a sequência é exibida, os botões não podem ser tocados.',
            ),
            _buildInstructionItem(
              title: 'Sua vez de jogar',
              description:
                  'Quando aparecer “Sua vez”, toque nos cartões na ordem que ouviu. Há um cronômetro de tempo limitado. Se o tempo acabar, o jogo termina.',
              semanticsDescription:
                  'Ao aparecer Sua vez, toque os cartões na ordem correta antes do tempo acabar.',
            ),
            _buildInstructionItem(
              title: 'Cronômetro',
              description:
                  'O cronômetro aparece no painel superior durante a sua jogada. Cada toque correto reinicia o tempo para a próxima entrada da sequência.',
              semanticsDescription:
                  'O cronômetro fica no painel superior durante sua vez.',
            ),
            _buildInstructionItem(
              title: 'Pontuação e níveis',
              description:
                  'Cada sequência completada aumenta sua pontuação e avança para o próximo nível. A dificuldade cresce gradualmente.',
              semanticsDescription:
                  'A cada sequência correta você ganha pontos e passa de nível.',
            ),
            _buildInstructionItem(
              title: 'Sons e cartões',
              description:
                  'Cada cartão representa um som: Bater Palma, Bater Pé, Bater Peito, Bater Perna, Gritar e Mandar Beijo. Toque duas vezes no cartão para selecioná-lo durante sua vez.',
              semanticsDescription:
                  'Cada cartão corresponde a um som. Toque duas vezes no cartão correto durante sua vez.',
            ),
            _buildInstructionItem(
              title: 'Reiniciar partida',
              description:
                  'Após “Fim de Jogo”, toque em “Jogar Novamente” para recomeçar do nível 1.',
              semanticsDescription:
                  'Após o fim de jogo, toque em Jogar Novamente para reiniciar.',
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
