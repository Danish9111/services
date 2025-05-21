import 'package:services/messaging/chatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:services/ServiceDetails/professionalDetail.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:services/providers.dart';

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
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('workerProfiles')
            .where('role', isEqualTo: serviceTitle)
            .get(),
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
                    contact: professional['contact'] ?? 'N/A',
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

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.contact_phone_rounded,
                    size: 40, color: Colors.blueGrey.shade800),
                const SizedBox(height: 16),
                Text(
                  'Contact $name',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  contact,
                  style: TextStyle(
                      fontSize: 16, color: textColor.withOpacity(0.7)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child:
                            Text('Close', style: TextStyle(color: textColor)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement call functionality
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade800,
                        ),
                        child: const Text('Call Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isDark
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey.shade50, Colors.white],
                  ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 3,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        imagePath,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: double.infinity,
                          color: Colors.grey.shade200,
                          child: Image.asset(
                            'assets/default_pic.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade800.withOpacity(0.85),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          '$experience Experience',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
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
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.03,
                  0,
                  screenWidth * 0.03,
                  screenHeight * 0.01,
                ),
                child: Row(
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
                        child: Center(
                      child: OutlinedButton.icon(
                        onPressed: () => _showContactDialog(context),
                        icon: Icon(
                          Icons.call,
                          size: screenWidth * 0.045,
                          color: Colors.orangeAccent,
                        ),
                        label: Text(
                          '',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: Colors.orangeAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          backgroundColor: isDark ? cardColor : null,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
