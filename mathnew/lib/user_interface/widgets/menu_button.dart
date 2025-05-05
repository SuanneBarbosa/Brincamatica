import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final String tooltip;
  final String semanticsLabel;
  final VoidCallback onTap;
  final double iconSize; 

  const MenuButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.tooltip,
    required this.onTap,
    required this.semanticsLabel,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = (iconSize * 0.24).clamp(10.0, 15.0);
    final double spacing = (iconSize * 0.08).clamp(2.0, 6.0);

    return Semantics(
      label: label,
      button: true,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  iconPath,
                  height: iconSize,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                  
                    return Container(
                      height: iconSize,
                      width: iconSize,
                      color: Colors.grey.shade300,
                      child: Icon(Icons.error_outline,
                          size: iconSize * 0.6, color: Colors.redAccent),
                    );
                  },
                ),
              ),
              SizedBox(height: spacing),
              Text(
                label,
                style: TextStyle(fontSize: fontSize),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
