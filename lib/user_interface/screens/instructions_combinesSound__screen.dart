// user_interface/screens/instructions_generator_screen.dart

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
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: ListView(
            children: [
              _buildInstructionItem(
                title: 'Objetivo do Jogo',
                description:
                    'Na tela do jogo, sua tarefa é usar os botões na parte inferior da tela para montar a sequência de sons correta. Conforme você acerta, a combinação é revelada na lista.',
                semanticsDescription:
                    'Seu objetivo é descobrir todas as combinações de sons.',
              ),
              _buildInstructionItem(
                title: 'Passo 1: Selecionar os Sons',
                description:
                    'Na primeira tela, toque para escolher 2 ou 3 sons que você quer usar no jogo. Após fazer sua escolha, toque no botão "Confirmar" no canto superior direito para avançar.',
                semanticsDescription:
                    'Escolha 2 ou 3 sons e depois toque em Confirmar.',
              ),
              _buildInstructionItem(
                title: 'Passo 2: Escolher o Modo de Jogo',
                description:
                    'Após confirmar os sons, escolha como quer jogar. As opções são: "Desafio por Níveis" (dificuldade progressiva, requer 3 sons), "Sem Repetição" (os sons não se repetem na mesma melodia) e "Com Repetição" (os sons podem se repetir).',
                semanticsDescription:
                    'Escolha um dos modos de jogo: Desafio, Sem Repetição ou Com Repetição.',
              ),
              _buildInstructionItem(
                title: 'Como Jogar',
                description:
                    'Na tela do jogo, sua tarefa é usar os botões na parte inferior da tela para montar a sequência de sons correta. Conforme você acerta, a combinação é revelada formando uma lista com suas combinações.',
                semanticsDescription:
                    'Use os botões na parte inferior para montar as sequências e revelá-las.',
              ),
              _buildInstructionItem(
                title: 'Ouvindo as Melodias',
                description:
                    'Após descobrir uma combinação, o botão "Ouvir" (ícone de play) ao lado dela será liberado. Toque nele a qualquer momento para escutar a melodia que você encontrou.',
                semanticsDescription:
                    'Após encontrar uma combinação, toque no botão Ouvir para escutá-la.',
              ),
              _buildInstructionItem(
                title: 'Feedback Imediato',
                description:
                   'A área de resposta, onde seus toques aparecem, muda de cor para avisar se a sequência está correta (verde) ou incorreta (vermelho). Um som de alerta também tocará para acertos e erros. Se errar, a área é limpa automaticamente para você tentar de novo.',
                semanticsDescription:
                    'A área de resposta toca um alerta para certo e outro alerta para errado.',
              ),
              _buildInstructionItem(
                title: 'Finalizando o Jogo',
                description:
                    'Quando você descobrir todas as combinações, clique no botão "Confirmar" para finalizar a partida. Se ainda faltarem melodias, o jogo avisará para você continuar tentando.',
                semanticsDescription:
                    'Após encontrar todas as melodias, clique no botão Confirmar para terminar.',
              ),
            ],
          ),
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