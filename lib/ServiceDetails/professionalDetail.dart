import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:services/messaging/chatScreen.dart';
import 'package:services/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final uid = FirebaseAuth.instance.currentUser?.uid;

class Professional {
  final String name,
      role,
      location,
      experience,
      profileImageUrl,
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
    required this.profileImageUrl,
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

class ProfessionalDetailPage extends ConsumerStatefulWidget {
  const ProfessionalDetailPage({super.key, required this.professionalId});
  final String professionalId;

  @override
  ConsumerState<ProfessionalDetailPage> createState() =>
      _ProfessionalDetailPageState();
}

class _ProfessionalDetailPageState
    extends ConsumerState<ProfessionalDetailPage> {
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAllPendingRatingDialogs(context);
      });
    }
  }

  Future<void> _showAllPendingRatingDialogs(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    // Prevent workers from rating themselves
    if (userId == widget.professionalId) return;
    QuerySnapshot? taskQuery;
    try {
      // Fetch all completed tasks for this user and professional
      taskQuery = await FirebaseFirestore.instance
          .collection('task')
          .where('professionalId', isEqualTo: widget.professionalId)
          .where('employerId', isEqualTo: userId)
          .where('status', isEqualTo: 'done')
          .get();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      return;
    }
    final unratedTasks = <QueryDocumentSnapshot>[];
    for (final doc in taskQuery.docs) {
      // Only show dialog if rating is null or 0 (not yet rated)
      final data = doc.data() as Map<String, dynamic>;
      if (data['rating'] == null || data['rating'] == 0) {
        unratedTasks.add(doc);
      }
    }
    if (unratedTasks.isNotEmpty) {
      await _showRatingDialogsSequentially(
          context, unratedTasks.map((doc) => doc.id).toList());
    }
  }

  Future<void> _showRatingDialogsSequentially(
      BuildContext context, List<String> taskIds) async {
    for (final taskId in taskIds) {
      // ignore: use_build_context_synchronously
      final submitted =
          await showRatingDialog(context, taskId, widget.professionalId);
      if (submitted == false) break; // Stop if user cancels
    }
  }

  Future<bool> showRatingDialog(
      BuildContext context, String taskId, String professionalId) async {
    double rating = 0;
    String reviewText = '';
    bool isSubmitting = false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Rate & Review this Professional'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Please rate your experience:'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                setState(() {
                                  rating = index + 1.0;
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        const Text('Leave a feedback (optional):'),
                        const SizedBox(height: 8),
                        TextField(
                          minLines: 2,
                          maxLines: 4,
                          onChanged: (val) => reviewText = val,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Write your review here...',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              Navigator.of(context).pop(false);
                            },
                      child: const Text('Cancel'),
                    ),
                    OutlinedButton(
                      onPressed: (rating > 0 && !isSubmitting)
                          ? () async {
                              setState(() => isSubmitting = true);
                              try {
                                // Save task review
                                final taskRef = FirebaseFirestore.instance
                                    .collection('task')
                                    .doc(taskId);
                                await taskRef.update({
                                  'rating': rating,
                                  'review': reviewText.trim(),
                                });

                                // Update professional's average rating
                                final ratedTasks = await FirebaseFirestore
                                    .instance
                                    .collection('task')
                                    .where('professionalId',
                                        isEqualTo: professionalId)
                                    .where('rating', isGreaterThan: 0)
                                    .get();

                                double total = 0;
                                int count = 0;

                                for (final doc in ratedTasks.docs) {
                                  final data = doc.data();
                                  if (data['rating'] != null &&
                                      data['rating'] > 0) {
                                    total += (data['rating'] as num).toDouble();
                                    count++;
                                  }
                                }

                                final workerRef = FirebaseFirestore.instance
                                    .collection('workerProfiles')
                                    .doc(professionalId);

                                await workerRef.update({
                                  'rating': count > 0 ? total / count : 0.0,
                                  'ratingCount': count,
                                });

                                Navigator.of(context).pop(true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Thank you for your rating and feedback!'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              } finally {
                                setState(() => isSubmitting = false);
                              }
                            }
                          : null,
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit'),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false; // Default fallback if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
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
            .doc(widget.professionalId)
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
            profileImageUrl: data['profileImageUrl'] ?? '',
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
                      ActionButtons(professionalId: widget.professionalId),
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
        const SizedBox(width: 20),
        CircleAvatar(
          radius: 40,
          backgroundImage: professional.profileImageUrl.isNotEmpty
              ? NetworkImage(professional.profileImageUrl)
              : const AssetImage('assets/default_pic.png') as ImageProvider,
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

    void addInfoItem(IconData icon, String text, String label) {
      if (text.isNotEmpty) {
        infoItems.add(
          _InfoRow(
            icon: icon,
            text: text,
            color: textColor,
            label: label,
          ),
        );
      }
    }

    addInfoItem(Icons.location_on, professional.location, 'Location');
    addInfoItem(Icons.calendar_today, professional.experience, 'Experience');
    addInfoItem(Icons.handyman, professional.services, 'Services');
    addInfoItem(Icons.attach_money, professional.fee, 'Fee');
    addInfoItem(
      Icons.directions_car,
      professional.radius.isNotEmpty
          ? 'Travel Radius ${professional.radius}'
          : '',
      'Radius',
    );
    addInfoItem(
      Icons.schedule,
      professional.availability.isNotEmpty
          ? ' ${professional.availability}'
          : '',
      'Availability',
    );

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
  final String label;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20, // Increased icon size
        ),
        const SizedBox(width: 8), // Slightly more space between icon and text
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16, // Increased label font size
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16, // Increased text font size
          ),
        ),
      ],
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
  const ActionButtons({super.key, required this.professionalId});
  final String professionalId;
  Future<void> createTask({
    // required String professionalId,
    required String taskDetails,
  }) async {
    final taskCollection = FirebaseFirestore.instance.collection('task');
    final docRef = taskCollection.doc(); // create a doc with custom ID

    await docRef.set({
      'taskId': docRef.id, // saving taskId inside task itself
      'professionalId': professionalId,
      'employerId': uid, // assuming uid is declared globally
      'taskDetails': taskDetails,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'acceptedByWorker': false,
      'acceptedByEmployer': false,
      'rating': 0.0,
      'ratingCount': 0,
      'review': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  showdialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> canAssignTask(String professionalId) async {
    final taskCollection = FirebaseFirestore.instance.collection('task');

    final existingTasks = await taskCollection
        .where('professionalId', isEqualTo: professionalId)
        .where('employerId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();

    return existingTasks
        .docs.isNotEmpty; // true = can assign, false = already assigned
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverId: professionalId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text('Chat'),
              ),
            )
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                try {
                  if (await canAssignTask(professionalId)) {
                    showdialog(
                      context: context,
                      title: 'Task already assigned',
                      content:
                          'You have already assigned a task to this professional.Please check your history.',
                    );
                    return;
                  }
                  await createTask(
                    taskDetails: 'Fix AC',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅Task Assigned')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error assigning task: $e')),
                  );
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Assign Task',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
        ),
      ],
    );
  }
}
