// lib/user_interface/screens/generator_instructions_screen.dart

import 'package:flutter/material.dart';

class GeneratorInstructionsScreen extends StatelessWidget {
  const GeneratorInstructionsScreen({super.key});

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
                  'O objetivo é recriar as melodias geradas pelo jogo. Você deve tocar nos ícones na mesma sequência em que eles foram originalmente combinados.',
            ),
            _buildInstructionItem(
              title: 'Passo 1: Selecionar os Sons',
              description:
                  'Na primeira tela, toque nos sons que você deseja usar para criar as melodias. Você pode escolher 2 ou 3 sons diferentes.',
            ),
            _buildInstructionItem(
              title: 'Passo 2: Escolher o Modo de Jogo',
              description:
                  'Após selecionar os sons, escolha como quer jogar: "Modo Livre" (com ou sem repetição) para praticar, ou "Desafio por Níveis" para um jogo com dificuldade progressiva (requer 3 sons).',
            ),
             _buildInstructionItem(
              title: 'Como Jogar',
              description:
                  'Na tela do jogo, uma melodia estará destacada em amarelo. Sua tarefa é tocá-la usando os ícones na parte inferior da tela. O primeiro som da melodia é mostrado como uma dica nos níveis iniciais.',
            ),
            _buildInstructionItem(
              title: 'Ouvindo as Melodias',
              description:
                  'Se tiver dúvidas, toque no botão de "Play" ao lado de qualquer melodia na lista para ouvi-la antes de tentar recriá-la.',
            ),
            _buildInstructionItem(
              title: 'Feedback',
              description:
                  'A caixa de entrada de sons mudará de cor para indicar se sua sequência está correta (verde) ou incorreta (vermelho). Se errar, a entrada será limpa para você tentar novamente.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.3,
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