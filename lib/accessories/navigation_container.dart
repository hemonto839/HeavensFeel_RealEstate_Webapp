import 'package:flutter/material.dart';

class NavigationContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const NavigationContainer({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle = "",
  });

 
  @override
  Widget build(BuildContext context) {
    // Use theme colors
    final backgroundColor = Theme.of(context).colorScheme.surface; // container bg
    final shadowColor = Theme.of(context).shadowColor.withOpacity(0.3);
    final titleColor = Theme.of(context).textTheme.titleMedium?.color ?? Colors.black;
    final subtitleColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54;


    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 3),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                )),
            if (subtitle.isNotEmpty)
              const SizedBox(height: 4),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  )),
          ],
        ),
      )
    );
  }
}