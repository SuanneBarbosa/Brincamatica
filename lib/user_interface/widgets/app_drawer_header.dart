import 'package:flutter/material.dart';

class AppDrawerHeader extends StatelessWidget {
  const AppDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      // Removemos o padding padrão para ter mais controle com o Stack
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Stack(
        children: [
          // Conteúdo principal centralizado
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  child: const Text(
                    'Apoio',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 1), // Aumentei um pouco o espaço
                Semantics(
                  label:
                      'Logotipos dos apoiadores: IFSP, CNPQ e RUMO à Educação Matemática Inclusiva',
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(2, 4))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // Usamos Flexible para os logos se ajustarem melhor
                      children: [
                        Flexible(
                          child: Image.asset('assets/images/IFSP_Logo.png',
                              height: 70, fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Image.asset('assets/images/CNPQ_Logo.png',
                              height: 70, fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Image.asset('assets/images/RUMO_Logo.png',
                              height: 70, fit: BoxFit.contain),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botão de fechar posicionado no canto superior direito
          Positioned(
            top: 0,
            right: 0,
            child: Semantics(
              label: 'Botão de Fechar menu',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Fechar menu',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}