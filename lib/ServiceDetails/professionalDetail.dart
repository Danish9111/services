import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:services/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  const ProfessionalDetailPage({super.key, required this.professionalId});
  final String professionalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = ref.watch(darkColorProvider);
    final cardColor = ref.watch(lightDarkColorProvider);
    final textColor = ref.watch(lightColorProvider);

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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('workerProfiles')
            .doc(professionalId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Professional not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final pro = Professional(
            name: data['name']?.isNotEmpty == true
                ? data['name']
                : 'Professional',
            rating: (data['rating'] ?? 0).toDouble(),
            role: data['role'] ?? '',
            location: data['location'] ?? '',
            experience: data['experience'] ?? '',
            services: data['services'] ?? '',
            fee: data['fee'] ?? '',
            radius: data['radius'] ?? '',
            availability: data['availability'] ?? '',
            verifiedBy: data['verifiedBy'] ?? '',
            review1: data['review1'] ?? '',
            review2: data['review2'] ?? '',
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeader(professional: pro, textColor: textColor),
                      const SizedBox(height: 18),
                      InfoSection(professional: pro, textColor: textColor),
                      if ((pro.review1.isNotEmpty ||
                          pro.review2.isNotEmpty)) ...[
                        const SizedBox(height: 14),
                        ReviewsSection(professional: pro, textColor: textColor),
                      ],
                      const SizedBox(height: 20),
                      const ActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final Professional professional;
  final Color textColor;

  const ProfileHeader({
    super.key,
    required this.professional,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: const AssetImage('assets/profile_pic.jpeg'),
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                professional.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (professional.rating > 0) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(
                      professional.rating.floor(),
                      (_) =>
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                    ),
                    if (professional.rating % 1 >= 0.5)
                      const Icon(Icons.star_half,
                          color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '(${professional.rating.toStringAsFixed(1)})',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ],
              if (professional.role.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  professional.role,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 15,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class InfoSection extends StatelessWidget {
  final Professional professional;
  final Color textColor;

  const InfoSection({
    super.key,
    required this.professional,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final infoItems = <Widget>[];

    void addInfoItem(IconData icon, String text) {
      if (text.isNotEmpty) {
        infoItems.add(_InfoRow(icon: icon, text: text, color: textColor));
      }
    }

    addInfoItem(Icons.location_on, professional.location);
    addInfoItem(Icons.calendar_today, professional.experience);
    addInfoItem(Icons.handyman, professional.services);
    addInfoItem(Icons.attach_money, professional.fee);
    addInfoItem(
        Icons.directions_car,
        professional.radius.isNotEmpty
            ? 'Travel Radius ${professional.radius}'
            : '');
    addInfoItem(
        Icons.schedule,
        professional.availability.isNotEmpty
            ? 'Availability ${professional.availability}'
            : '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        if (infoItems.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...infoItems,
          const SizedBox(height: 10),
        ],
        const Divider(),
        if (professional.verifiedBy.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.blue, size: 20),
              const SizedBox(width: 6),
              Text(
                'Verified by ${professional.verifiedBy}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewsSection extends StatelessWidget {
  final Professional professional;
  final Color textColor;

  const ReviewsSection({
    super.key,
    required this.professional,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final reviews = [
      if (professional.review1.isNotEmpty) professional.review1,
      if (professional.review2.isNotEmpty) professional.review2,
    ];

    if (reviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        ...reviews
            .map((review) => _ReviewCard(review: review, color: textColor)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String review;
  final Color color;

  const _ReviewCard({
    required this.review,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              review,
              style: TextStyle(
                color: color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orangeAccent,
              side: const BorderSide(color: Colors.orangeAccent),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {},
            icon: const Icon(Icons.call, color: Colors.orangeAccent),
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
            icon: const Icon(Icons.chat, color: Colors.white),
            label: const Text('Chat'),
          ),
        )
      ],
    );
  }
}
