import 'package:flutter/material.dart';

class NavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;
  final IconData? icon;
  final String? imagePath;

  const NavigationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
    this.icon,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final shadowColor = Theme.of(context).shadowColor.withOpacity(0.2);
    final titleColor =
        Theme.of(context).textTheme.titleLarge?.color ?? Colors.black;
    final subtitleColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black54;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Show image if provided, else show icon if provided
          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
          else if (icon != null)
            Icon(
              icon,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 16,color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
