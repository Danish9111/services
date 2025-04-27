import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:services/providers.dart';

final professionalProvider = Provider<Professional>((ref) {
  return Professional(
    name: 'Ali Khan',
    rating: 4.5,
    role: 'AC Technician',
    location: 'Lahore, Gulberg',
    experience: '5 Years',
    services: 'Window AC, Split AC',
    fee: 'Rs. 1500 / Visit',
    radius: '10 km',
    availability: '10am–7pm',
    verifiedBy: 'XYZ Institute',
    review1: '“Very polite and quick service!”',
    review2: '“Affordable and professional.”',
  );
});

class Professional {
  final String name,
      role,
      location,
      experience,
      services,
      fee,
      radius,
      availability,
      verifiedBy,
      review1,
      review2;
  final double rating;

  Professional({
    required this.name,
    required this.rating,
    required this.role,
    required this.location,
    required this.experience,
    required this.services,
    required this.fee,
    required this.radius,
    required this.availability,
    required this.verifiedBy,
    required this.review1,
    required this.review2,
  });
}

class ProfessionalDetailPage extends HookConsumerWidget {
  const ProfessionalDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = ref.watch(darkColorProvider);
    final cardColor = ref.watch(lightDarkColorProvider);
    final textColor = ref.watch(lightColorProvider);
    final pro = ref.watch(professionalProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Professional Details', style: TextStyle(color: textColor)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            const AssetImage('assets/profile_pic.jpeg'),
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pro.name,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                ...List.generate(
                                    pro.rating.floor(),
                                    (_) => const Icon(Icons.star,
                                        color: Colors.amber, size: 18)),
                                if (pro.rating % 1 >= 0.5)
                                  const Icon(Icons.star_half,
                                      color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text('(${pro.rating})',
                                    style: TextStyle(color: textColor)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(pro.role,
                                style: TextStyle(
                                    color: textColor.withOpacity(0.7),
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  infoRow(Icons.location_on, pro.location, textColor),
                  infoRow(Icons.calendar_today, pro.experience, textColor),
                  infoRow(Icons.handyman, pro.services, textColor),
                  infoRow(Icons.attach_money, pro.fee, textColor),
                  infoRow(Icons.directions_car, 'Travel Radius  ${pro.radius}',
                      textColor),
                  infoRow(Icons.schedule, 'Availability  ${pro.availability}',
                      textColor),
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.blue, size: 20),
                      const SizedBox(width: 6),
                      Text('Verified by ${pro.verifiedBy}',
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Reviews',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 16)),
                  const SizedBox(height: 6),
                  reviewCard(pro.review1, textColor),
                  reviewCard(pro.review2, textColor),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orangeAccent,
                            side: const BorderSide(color: Colors.orangeAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.call,
                            color: Colors.orangeAccent,
                          ),
                          label: const Text('Call'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.chat,
                            color: Colors.white,
                          ),
                          label: const Text('Chat'),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text, style: TextStyle(color: color, fontSize: 15))),
        ],
      ),
    );
  }

  Widget reviewCard(String review, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: Colors.amber, size: 18),
          const SizedBox(width: 6),
          Expanded(
              child: Text(review,
                  style: TextStyle(color: color, fontStyle: FontStyle.italic))),
        ],
      ),
    );
  }
}
