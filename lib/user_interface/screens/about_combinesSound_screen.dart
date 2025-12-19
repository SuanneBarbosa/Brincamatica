import 'package:flutter/material.dart';

class AboutGeneratorScreen extends StatelessWidget {
  const AboutGeneratorScreen({super.key});
  static const String _appVersion = 'Versão 1.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(220, 247, 255, 1.0),
      appBar: AppBar(
        title: const Text("Sobre"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
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
                'Combina Som',
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
                _appVersion, 
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
              'Combina Som é um jogo que explore o mundo dos sons, descubra padrões e treine sua memória de uma forma divertida e interativa!',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Principais Funcionalidades'),
            _buildFeatureItem(Icons.music_note_outlined, 'Comece a Combinar:',
                'Selecione 2 ou 3 sons para dar início ao desafio e descobrir todas as combinações que eles podem formar.'),
            _buildFeatureItem(
                Icons.touch_app_outlined,
                'Jogabilidade Intuitiva:',
                'Ao formar uma sequência, o jogo informa imediatamente se sua combinação está correta, permitindo que você aprenda e avance para o próximo nível.'),
            _buildFeatureItem(
                Icons.trending_up_outlined,
                'Níveis Progressivos:',
                'Comece com combinações simples e avance para desafios complexos, incluindo fases sem dicas que testarão sua memória auditiva.'),
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
                  Flexible(
                    child: Image.asset('assets/images/IFSP_Logo.png',
                        height: 60, fit: BoxFit.contain),
                  ),
                  Flexible(
                    child: Image.asset('assets/images/CNPQ_Logo.png',
                        height: 60, fit: BoxFit.contain),
                  ),
                  Flexible(
                    child: Image.asset('assets/images/RUMO_Logo.png',
                        height: 60, fit: BoxFit.contain),
                  ),
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
      padding: const EdgeInsets.only(bottom: 12.0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24), 
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 16, color: Colors.black87, height: 1.4), 
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
