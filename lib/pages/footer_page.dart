import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.canvasColor,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildFooterChildren(context, isMobile),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildFooterChildren(context, isMobile),
                );
        },
      ),
    );
  }

  List<Widget> _buildFooterChildren(BuildContext context, bool isMobile) {
  return [
    // Left Section — Branding + address/contact
    isMobile
        ? _buildBrandingSection() // plain Column in mobile
        : Expanded(flex: 2, child: _buildBrandingSection()),

    SizedBox(width: isMobile ? 0 : 60, height: isMobile ? 32 : 0),

    // About Section
    isMobile
        ? _buildAboutSection(context) 
        : Expanded(flex: 1, child: _buildAboutSection(context)),

    SizedBox(width: isMobile ? 0 : 60, height: isMobile ? 32 : 0),

    // Legal Section
    isMobile
        ? _buildLegalSection(context)
        : Expanded(flex: 1, child: _buildLegalSection(context)),
  ];
}

// 👇️ Extracted helper widgets so they can be reused
Widget _buildBrandingSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text("HeavensFeel",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      SizedBox(height: 12),
      Text("CSE 347 Project"),
      Text("System Design and Analysis"),
      Text("Contact: contact@heavensfeel.com"),
      Text("Phone: +880 1900-000000"),
      SizedBox(height: 16),
      Text("© 2025 HeavensFeel. All rights reserved."),
    ],
  );
}

Widget _buildAboutSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("ABOUT",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _buildFooterLink(context, "About Us"),
      _buildFooterLink(context, "Contact"),
      _buildFooterLink(context, "Advertise"),
      _buildFooterLink(context, "Sitemap"),
    ],
  );
}

Widget _buildLegalSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("LEGAL",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _buildFooterLink(context, "Terms of Service"),
      _buildFooterLink(context, "Privacy Policy"),
      _buildFooterLink(context, "Accessibility"),
      _buildFooterLink(context, "GDPR Compliance"),
    ],
  );
}

  Widget _buildFooterLink(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          if (text == "Terms of Service") {
            // Navigate to Terms of Service page
          } else if (text == "Privacy Policy") {
            // Navigate to Privacy Policy page
          } else if (text == "Accessibility") {
            // Navigate to Accessibility page
          } else if (text == "GDPR Compliance") {
            // Navigate to GDPR Compliance page
          } else if (text == "About Us") {
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                title: const Text("About Us"),
                content: const Text(
                  "CSE 347 Project\n"
                  "HeavensFeel Real Estate Management System\n"
                  "Developed by:\n"
                  "MD. Robiul Islam\n"
                  "ID: 2023-1-60-093\n"
                  "Sunzid Ashraf Mahi\n"
                  "ID: 2023-1-60-148\n"
                  "Arka Roy\n"
                  "ID: 2023-1-60-213\n"
                  "Fahim Monaym\n"
                  "ID: 2023-1-60-219",
                  textAlign: TextAlign.left, // optional
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            });
          } else if (text == "Contact") {
            // Navigate to Contact page
          } else if (text == "Advertise") {
            // Navigate to Advertise page
          } else if (text == "Sitemap") {
            // Navigate to Sitemap page
          }
        },
        child: Text(
          text,
          style: const TextStyle( fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}