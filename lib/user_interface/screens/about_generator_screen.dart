// lib/user_interface/screens/about_generator_screen.dart

import 'package:flutter/material.dart';

class AboutGeneratorScreen extends StatelessWidget {
  const AboutGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 20),
            _buildSupportCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Gerador de Sons e Imagens',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Versão 1.0',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
            const Divider(height: 30),
            _buildSectionTitle('O que é?'),
            const Text(
              'Um jogo interativo para explorar combinações de sons! Selecione seus sons favoritos e o jogo gerará todas as melodias possíveis para você ouvir e tentar replicar.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Principais Funcionalidades'),
            _buildFeatureItem(Icons.music_note_outlined, 'Selecione os Sons:',
                'Escolha 2 ou 3 sons da nossa biblioteca para começar a brincadeira.'),
            _buildFeatureItem(Icons.shuffle, 'Geração Automática:',
                'O aplicativo cria todas as combinações de melodias possíveis com os sons que você escolheu.'),
            _buildFeatureItem(
                Icons.touch_app_outlined,
                'Desafio Interativo:',
                'Tente recriar as melodias tocando nos sons na ordem correta. O jogo dá feedback instantâneo se você acertou ou errou.'),
            _buildFeatureItem(
                Icons.trending_up_outlined,
                'Modo Desafio:',
                'Enfrente níveis de dificuldade crescente, começando com melodias simples e avançando para sequências mais complexas e sem dicas visuais.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSectionTitle('Apoio Institucional'),
            const SizedBox(height: 15),
            Semantics(
              label:
                  'Logotipos dos apoiadores: IFSP, CNPQ e RUMO à Educação Matemática Inclusiva',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/IFSP_Logo.png',
                      height: 60, fit: BoxFit.contain),
                  Image.asset('assets/images/CNPQ_Logo.png',
                      height: 60, fit: BoxFit.contain),
                  Image.asset('assets/images/RUMO_Logo.png',
                      height: 60, fit: BoxFit.contain),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 15, color: Colors.black87, height: 1.3),
                children: [
                  TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}