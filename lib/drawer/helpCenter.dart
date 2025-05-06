import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/providers.dart';

// Assume these providers are defined in your separate file.

class HelpCenterPage extends ConsumerWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkColorPro = ref.watch(darkColorProvider);
    final lightColorPro = ref.watch(lightColorProvider);

    return Scaffold(
      backgroundColor: darkColorPro,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        shadowColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Help Center",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 72, 76),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: darkColorPro,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'How can we help you?',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // FAQ Section
              _buildFAQSection(lightColorPro, darkColorPro),

              const SizedBox(height: 30),

              // Contact Support
              // _buildContactSection(lightColorPro, darkColorPro),

              const SizedBox(height: 20),

              // Additional Resources
              _buildResourcesSection(lightColorPro),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(dynamic lightColorPro, dynamic darkColorPro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Common Questions',
          style: TextStyle(
            color: lightColorPro,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildFAQItem(
          question: "How do I book a service?",
          answer:
              "Select your desired service from the homepage, choose your preferred time slot, and confirm your booking.",
          lightColorPro: lightColorPro,
          darkColorPro: darkColorPro,
        ),
        _buildFAQItem(
          question: "What payment methods are accepted?",
          answer:
              "We accept credit/debit cards, mobile wallets, and cash payments.",
          lightColorPro: lightColorPro,
          darkColorPro: darkColorPro,
        ),
        _buildFAQItem(
          question: "How to cancel a booking?",
          answer:
              "Go to 'My Bookings' section, select the booking you want to cancel, and follow the cancellation process.",
          lightColorPro: lightColorPro,
          darkColorPro: darkColorPro,
        ),
      ],
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required dynamic lightColorPro,
    required dynamic darkColorPro,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          color: lightColorPro,
          fontSize: 16,
        ),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      backgroundColor: darkColorPro,
      collapsedBackgroundColor: darkColorPro,
      trailing: const Icon(Icons.chevron_right, color: Colors.orange),
      iconColor: Colors.orange,
      collapsedIconColor: Colors.orange,
      children: [
        Text(
          answer,
          style: TextStyle(
            color: lightColorPro,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // Widget _buildContactSection(dynamic lightColorPro, dynamic darkColorPro) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: darkColorPro,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Need more help?',
  //           style: TextStyle(
  //             color: Colors.orange,
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         Text(
  //           'Contact our support team:',
  //           style: TextStyle(
  //             color: lightColorPro,
  //             fontSize: 16,
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         _buildContactOption(
  //             Icons.email, "nadeemdanish.9188.1@gmail.com", lightColorPro),
  //         _buildContactOption(Icons.phone, "03144881902", lightColorPro),
  //         const SizedBox(height: 10),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildContactOption(
  //     IconData icon, String text, dynamic lightColorPro) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     child: Row(
  //       children: [
  //         Icon(icon, color: Colors.orange, size: 20),
  //         const SizedBox(width: 10),
  //         Text(
  //           text,
  //           style: TextStyle(
  //             color: lightColorPro,
  //             fontSize: 14,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildResourcesSection(dynamic lightColorPro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resources',
          style: TextStyle(
            color: lightColorPro,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildResourceItem(Icons.security, "Safety Guidelines", lightColorPro),
        _buildResourceItem(Icons.payment, "Payment Help", lightColorPro),
        _buildResourceItem(
            Icons.assignment, "Service Agreements", lightColorPro),
      ],
    );
  }

  Widget _buildResourceItem(IconData icon, String text, dynamic lightColorPro) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(
        text,
        style: TextStyle(
          color: lightColorPro,
          fontSize: 16,
        ),
      ),
      // trailing: const Icon(Icons.chevron_right, color: Colors.orange),
    );
  }
}
