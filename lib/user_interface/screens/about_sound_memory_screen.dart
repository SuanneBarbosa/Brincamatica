import 'package:flutter/material.dart';

class AboutSoundMemoryScreen extends StatelessWidget {
  const AboutSoundMemoryScreen({super.key});

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
                'Jogo da Memória',
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
              'Um jogo da memória com sons! Pressione "Iniciar", ouça os sons das cartas e encontre todos os pares, fazendo-os desaparecer até limpar o tabuleiro.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Principais Funcionalidades'),
            _buildFeatureItem(Icons.play_circle_outline, 'Inicie o Desafio:',
                'Pressione o botão "Iniciar" para começar a partida e ativar o cronômetro. O objetivo é limpar o tabuleiro no menor tempo possível.'),
            _buildFeatureItem(Icons.pin, 'Vire, Ouça e Memorize:',
                'Cada carta numerada esconde um som. Toque para virá-la, ouvir o som e usar o número como referência.'),
            _buildFeatureItem(Icons.check_circle_outline, 'Pares que Desaparecem:',
                'Se os sons de duas cartas forem iguais, você encontrou um par! Um som de acerto tocará e as cartas desaparecerão da tela.'),
            _buildFeatureItem(
                Icons.timer_outlined,
                'Cronômetro:',
                'Um cronômetro marca seu tempo de jogo. Ao final, seu o tempo total será exibido. Tente bater seu recorde de tempo!'),
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