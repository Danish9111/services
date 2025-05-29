import 'package:services/messaging/chatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:services/ServiceDetails/professionalDetail.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:services/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailPage extends ConsumerWidget {
  final String serviceTitle;

  const ServiceDetailPage({super.key, required this.serviceTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = ref.watch(darkColorProvider);
    final cardColor = ref.watch(lightDarkColorProvider);
    final textColor = ref.watch(lightColorProvider);
    final isDark = ref.watch(isDarkProvider);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Text(
          serviceTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('workerProfiles')
            .where('role', isEqualTo: serviceTitle)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error occurred: \\${snapshot.error.toString()}',
                    style: TextStyle(color: textColor)));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return NoProfessionalsFound(textColor: textColor);
          } else {
            final professionals = snapshot.data!.docs;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                itemCount: professionals.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final professional = professionals[index].data();
                  final professionalDoc = snapshot.data!.docs[index];
                  final professionalId = professionalDoc.id;
                  return ProfessionalCard(
                    professionalId: professionalId,
                    name: professional['name'] ?? 'Unknown',
                    experience: professional['experience'] ?? 'N/A',
                    rating: (professional['rating'] as num?)?.toDouble() ?? 0.0,
                    imagePath: professional['profileImageUrl'] ??
                        'assets/default_pic.png',
                    contact: professional['phone'] ?? 'c/A',
                    isVerified: professional['isVerified'] as bool? ?? true,
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class NoProfessionalsFound extends StatelessWidget {
  final Color textColor;
  const NoProfessionalsFound({super.key, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied,
              color: textColor.withOpacity(0.7), size: 60),
          const SizedBox(height: 18),
          Text(
            'No professionals found',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different service or check back later.',
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ProfessionalCard extends StatelessWidget {
  final String name;
  final String professionalId;
  final String experience;
  final double rating;
  final String imagePath;
  final String contact;
  final bool isVerified;
  final Color cardColor;
  final Color textColor;
  final bool isDark;

  const ProfessionalCard({
    super.key,
    required this.professionalId,
    required this.name,
    required this.experience,
    required this.rating,
    required this.imagePath,
    required this.contact,
    this.isVerified = true,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
  });

  void openDialer(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch dialer for $phoneNumber'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProfessionalDetailPage(professionalId: professionalId),
        ),
      ),
      child: Card(
        elevation: 4,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: screenWidth * 0.025, horizontal: screenWidth * 0.02),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: imagePath.isNotEmpty
                        ? (imagePath.startsWith('http')
                            ? NetworkImage(imagePath)
                            : AssetImage(imagePath) as ImageProvider)
                        : null,
                    onBackgroundImageError: (_, __) {},
                    child: imagePath.isEmpty
                        ? const Icon(Icons.person, size: 30, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                flex: 3,
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified)
                          Icon(Icons.verified,
                              color: Colors.blue, size: screenWidth * 0.045),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: [
                            ...List.generate(
                                rating.floor(),
                                (i) => Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber.shade600,
                                      size: screenWidth * 0.045,
                                    )),
                            if (rating - rating.floor() >= 0.5)
                              Icon(Icons.star_half_rounded,
                                  color: Colors.amber.shade600,
                                  size: screenWidth * 0.045),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: textColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (experience.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "$experience Experience",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChatScreen(
                                  receiverId: professionalId,
                                )),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Icon(
                        Icons.message,
                        size: screenWidth * 0.045,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => openDialer(contact, context),
                      icon: Center(
                        child: Icon(
                          Icons.call,
                          size: screenWidth * 0.045,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      label: const SizedBox.shrink(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: Colors.orangeAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        backgroundColor: isDark ? cardColor : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
