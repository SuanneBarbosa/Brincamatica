
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                'Criar Melodia',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Versão 1.3',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
            const Divider(height: 30),
            _buildSectionTitle('O que é o App?'),
            const Text(
              'Criar Melodia é uma ferramenta educacional que transforma a composição musical em uma atividade visual e interativa.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Principais Funcionalidades'),
            _buildFeatureItem(Icons.grid_on, 'Criação Visual:', 'Arraste o beija-flor pela grade e adicione ícones de ação (palmas, assobios, batidas) para construir sua sequência rítmica.'),
            _buildFeatureItem(Icons.play_circle_outline, 'Reprodução Instantânea:', 'Toque "Play" para ver o beija-flor percorrer sua criação, tocando cada som em ordem.'),
            _buildFeatureItem(Icons.save, 'Salve e Reutilize:', 'Guarde suas sequências favoritas e aplique-as em diferentes linhas para criar composições mais complexas.'),
            _buildFeatureItem(Icons.accessibility_new, 'Personalização e Acessibilidade:', 'Escolha seu personagem, ajuste o tamanho dos ícones e utilize o joystick para uma navegação facilitada.'),
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
              label: 'Logotipos dos apoiadores: IFSP, CNPQ e RUMO à Educação Matemática Inclusiva',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/IFSP_Logo.png', height: 60, fit: BoxFit.contain),
                  Image.asset('assets/images/CNPQ_Logo.png', height: 60, fit: BoxFit.contain),
                  Image.asset('assets/images/RUMO_Logo.png', height: 60, fit: BoxFit.contain),
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
                style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.3),
                children: [
                  TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' $description'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}