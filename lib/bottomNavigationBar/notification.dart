import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Import Slidable
import '../providers.dart'; // Your theme providers
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends ConsumerWidget {
  Color darkMode = const Color.fromARGB(255, 63, 72, 76);
  NotificationsPage({super.key});
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkColorPro = ref.watch(darkColorProvider);
    final lightColorPro = ref.watch(lightColorProvider);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
            color: Colors.white), // <- this makes back arrow white

        shape: darkMode == darkColorPro
            ? const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
              )
            : const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
        title: const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text('Notifications', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 72, 76),
        centerTitle: true,
      ),
      body: Container(
        color: darkColorPro,
        // padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('task')
              .where('professionalId', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading notifications'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = snapshot.data!.docs;

            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('No notifications yet',
                        style: TextStyle(
                          color: lightColorPro,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 8),
                    const Text('You will see your job offers and updates here.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        )),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final doc = tasks[index];
                final taskId = doc['taskId'];
                final taskDetails = doc['taskDetails'] ?? '';
                final status = doc['status'] ?? 'pending';
                final isUnread = status == 'pending';

                final createdAt = doc['createdAt'];
                String timeString = '';
                String dateString = '';
                if (createdAt != null) {
                  try {
                    final dt = (createdAt is Timestamp)
                        ? createdAt.toDate()
                        : DateTime.tryParse(createdAt.toString());
                    if (dt != null) {
                      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
                      final minute = dt.minute.toString().padLeft(2, '0');
                      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
                      timeString = '$hour:$minute $ampm';
                      dateString =
                          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                    }
                  } catch (_) {}
                }

                String? localDecision;
                if (status == 'acceptedByWorker') localDecision = 'accepted';
                if (status == 'rejectedByWorker') localDecision = 'rejected';

                return Slidable(
                  key: Key(taskId ?? doc.id),
                  // Use doc.id as fallback for unique key
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await FirebaseFirestore.instance
                              .collection('task')
                              .doc(doc.id)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Notification deleted')),
                          );
                        },
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (status == 'pending') {
                        final result = await showDialog<String>(
                          context: context,
                          builder: (_) => TaskOfferDialog(
                            taskDetails: taskDetails,
                            darkColorPro: darkColorPro,
                            lightColorPro: lightColorPro,
                            onAccept: () async {
                              await FirebaseFirestore.instance
                                  .collection('task')
                                  .doc(doc.id)
                                  .update({'status': 'acceptedByWorker'});
                              Navigator.of(context, rootNavigator: true)
                                  .pop('accepted');
                            },
                            onCancel: () async {
                              await FirebaseFirestore.instance
                                  .collection('task')
                                  .doc(doc.id)
                                  .update({'status': 'rejectedByWorker'});
                              Navigator.of(context, rootNavigator: true)
                                  .pop('rejected');
                            },
                          ),
                        );
                        // if (result == null) return;
                        // // Show info dialog after decision
                        // await showDialog(
                        //   context: context,
                        //   builder: (_) => AlertDialog(
                        //     backgroundColor: darkColorPro,
                        //     title: Text('Offer ${result == 'accepted' ? 'Accepted' : 'Rejected'}',
                        //         style: TextStyle(color: lightColorPro)),
                        //     content: const Text(
                        //       'You can visit history to see progress.',
                        //       style: TextStyle(color: Colors.grey),
                        //     ),
                        //     actions: [
                        //       TextButton(
                        //         onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                        //         child: const Text('OK'),
                        //       ),
                        //     ],
                        //   ),
                        // );
                      } else {
                        // Always allow tap, show info dialog
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: darkColorPro,
                            title: Text('Offer Status',
                                style: TextStyle(color: lightColorPro)),
                            content: const Text(
                              'You can visit history to see progress.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: status == 'pending'
                            ? Colors.blue.shade100
                            : Colors.white,
                        border: const Border(
                            bottom: BorderSide(color: Colors.grey)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notification',
                                style: TextStyle(
                                    color: status == 'pending'
                                        ? darkColorPro
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(taskDetails,
                                style: TextStyle(
                                    color: status == 'pending'
                                        ? darkColorPro
                                        : Colors.grey)),
                            if (status == 'acceptedByWorker')
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('Offer accepted',
                                    style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600)),
                              ),
                            if (status == 'rejectedByWorker')
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('Offer rejected',
                                    style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w600)),
                              ),
                            // Add a Row for date and time at the bottom right
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.notifications,
                                        size: 18,
                                        color: status == 'pending'
                                            ? darkColorPro
                                            : Colors.grey),
                                    const SizedBox(width: 4),
                                    if (dateString.isNotEmpty)
                                      Text(dateString,
                                          style: TextStyle(
                                              color: status == 'pending'
                                                  ? darkColorPro
                                                  : Colors.grey,
                                              fontSize: 12)),
                                    if (dateString.isNotEmpty &&
                                        timeString.isNotEmpty)
                                      const SizedBox(width: 6),
                                    if (timeString.isNotEmpty)
                                      Text(timeString,
                                          style: TextStyle(
                                              color: status == 'pending'
                                                  ? darkColorPro
                                                  : Colors.grey,
                                              fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Add this widget at the bottom of your file (outside NotificationsPage)

class TaskOfferDialog extends StatelessWidget {
  final String taskDetails;
  final Color darkColorPro;
  final Color lightColorPro;
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  const TaskOfferDialog({
    super.key,
    required this.taskDetails,
    required this.darkColorPro,
    required this.lightColorPro,
    required this.onAccept,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: darkColorPro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Task Offer',
        style: TextStyle(
          color: lightColorPro,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Text(
          taskDetails,
          style: TextStyle(
            color: lightColorPro.withOpacity(0.9),
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: lightColorPro,
          ),
          child: const Text('Reject',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: onAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Accept Offer',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
