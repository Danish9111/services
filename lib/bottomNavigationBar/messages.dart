import 'package:services/messaging/chatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/providers.dart'; // Make sure this file exports darkColorProvider and lightColorProvider

class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  MessagePageState createState() => MessagePageState();
}

class MessagePageState extends ConsumerState<MessagePage> {
  // Track dismissed conversation sender IDs locally.
  final Set<String> dismissedSenderIds = {};
  StreamSubscription<QuerySnapshot>? _subscription;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _isActive = true;
    // Add message listener
    _subscription = FirebaseFirestore.instance
        .collection('chatss')
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('status', whereIn: ['sent', 'received'])
        .snapshots()
        .listen((snapshot) {
          // Update badge count here
          final unreadCount = snapshot.docs.length;
          // Update your badge UI accordingly.
        });
  }

  @override
  void dispose() {
    _isActive = false;
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> updateAllUnreadMessages(String senderId, String chatId) async {
    if (!_isActive) return;

    await FirebaseFirestore.instance
        .collection('chatss')
        .where('senderId', isEqualTo: senderId)
        .where('chatId', isEqualTo: chatId)
        .where('status', whereIn: ['sent', 'received'])
        .get()
        .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({'status': 'read'});
          }
        });
  }

  // Helper method to generate chatId
  String getChatId(String a, String b) {
    return a.compareTo(b) < 0 ? '$a-$b' : '$b-$a';
  }

  Future<void> removeIsReadField() async {
    try {
      // Get all documents from chatss collection
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('chatss').get();

      // Create a batch write
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('isRead')) {
          // Remove isRead field using FieldValue.delete()
          batch.update(doc.reference, {
            'isRead': FieldValue.delete(),
          });
        }
      }

      // Commit the batch
      await batch.commit();
      print('Successfully removed isRead field from Firebase');
    } catch (e) {
      print('Error removing isRead field from Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    // Use your Riverpod providers
    final darkColorPro = ref.watch(darkColorProvider);
    final lightColorPro = ref.watch(lightColorProvider);
    // Card/message background (you can adjust this as needed)
    const darkColor = Color.fromARGB(255, 63, 72, 76);
    final isDark = ref.watch(isDarkProvider);
    const cardColor = Color.fromARGB(1, 193, 193, 193);

    return Scaffold(
      appBar: AppBar(
        // leading: const BackButton(color: Colors.white),

        elevation: 2,
        shadowColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Messages",
            style: TextStyle(color: Colors.white),
          ),
        ),
        centerTitle: true,
        backgroundColor: darkColor,
        // iconTheme: IconThemeData(color: lightColorPro),
        actions: [
          _buildStatusFilter(darkColor, lightColorPro),
        ],
      ),
      backgroundColor: darkColorPro,
      body: _isActive
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatss')
                  .where('receiverId', isEqualTo: currentUser!.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: lightColorPro),
                  ));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages',
                      style: TextStyle(color: lightColorPro),
                    ),
                  );
                }

                // Map to store the latest message for each sender, ignoring dismissed senders.
                Map<String, QueryDocumentSnapshot> latestMessages = {};

                for (var doc in messages) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String senderId = data['senderId'];
                  // Skip if this conversation was dismissed.
                  if (dismissedSenderIds.contains(senderId)) continue;

                  if (!latestMessages.containsKey(senderId)) {
                    latestMessages[senderId] = doc;
                  }
                }

                final latestMessagesList = latestMessages.values.toList();

                return ListView.separated(
                  itemCount: latestMessagesList.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 0.5,
                    color: lightColorPro.withOpacity(0.5),
                  ),
                  itemBuilder: (context, index) {
                    final doc = latestMessagesList[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final bool isRead = data['status'] == 'read';
                    final Timestamp ts = data['timestamp'] as Timestamp;
                    final DateTime date = ts.toDate();
                    final String formattedDate =
                        DateFormat('dd-MM-yyyy ').format(date);
                    final String formattedTime =
                        DateFormat('hh:mm a').format(date);

                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: const Color.fromARGB(255, 255, 129, 129),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(height: 4),
                            Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          // Add the senderId of the dismissed conversation to the set.
                          dismissedSenderIds.add(data['senderId']);
                        });
                      },
                      child: Container(
                        color: !isDark ? Colors.white : cardColor,
                        width: double.infinity,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: lightColorPro,
                                child: Image.network(
                                  data['senderPhoto'] ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['text'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: data['status'] == 'read'
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          color: lightColorPro,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      color: lightColorPro,
                                      fontSize: 12,
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: lightColorPro,
                                      fontSize: 12,
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          onTap: () async {
                            final chatId =
                                getChatId(currentUser.uid, data['senderId']);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                    receiverId: data['senderId'] ?? ''),
                              ),
                            );
                            if (data['status'] != 'read') {
                              await updateAllUnreadMessages(
                                  data['senderId'], chatId);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildStatusFilter(Color darkColor, Color lightColor) {
    return PopupMenuButton<JobStatus>(
      onSelected: (status) => setState(() {}),
      itemBuilder: (_) => JobStatus.values.map((status) {
        return PopupMenuItem<JobStatus>(
          value: status,
          child: Row(
            children: [
              Icon(
                status.icon,
                color: status.backgroundColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                status.label,
                style: TextStyle(color: lightColor),
              ),
            ],
          ),
        );
      }).toList(),
      color: darkColor,
      icon: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 20),
        child: Icon(
          Icons.filter_list,
          color: lightColor,
        ),
      ),
    );
  }
}

enum JobStatus {
  all('All', Icons.all_inclusive, Colors.grey, Colors.grey),
  completed('Completed', Icons.check_circle, Colors.green, Colors.white),
  inProgress('In Progress', Icons.access_time, Colors.orange, Colors.white),
  cancelled('Cancelled', Icons.cancel, Colors.red, Colors.white);

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const JobStatus(
    this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
  );
}
