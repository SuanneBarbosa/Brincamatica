import 'package:flutter/material.dart';

class MemoryGameAboutScreen extends StatelessWidget {
  const MemoryGameAboutScreen({super.key});

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
                'Sheldon',
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
                'Versão 2.0',
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
              'Um jogo de memória auditiva e visual: ouça a sequência de sons/ícones e repita na mesma ordem. '
              'A cada nível a sequência cresce e o desafio aumenta.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Principais Funcionalidades'),
            _buildFeatureItem(Icons.visibility_outlined, 'Ouça a sequência:',
                'os cartões são destacados um a um e seus sons são reproduzidos automaticamente para você memorizar a ordem.'),
            _buildFeatureItem(Icons.touch_app_outlined, 'Repita na sua vez:',
                'quando a exibição termina, toque nos cartões na mesma ordem apresentada. Um cronômetro no topo indica o tempo restante.'),
            _buildFeatureItem(
                Icons.trending_up_outlined,
                'Progressão de níveis:',
                'a cada acerto a sequência ganha um novo som, aumentando gradualmente a dificuldade e sua pontuação.'),
            _buildFeatureItem(
                Icons.volume_up_outlined,
                'Feedback sonoro e visual:',
                'cada cartão possui um som próprio (palmas, assobio, batidas, etc.) e realce visual durante a exibição e a sua jogada.'),
            _buildFeatureItem(Icons.accessibility_new, 'Acessibilidade:',
                'indicadores de estado são anunciados por leitor de tela (ex.: “Ouça a sequência”, “Sua vez”) e os cartões têm rótulos semânticos claros.'),
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
