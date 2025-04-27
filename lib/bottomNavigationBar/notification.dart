import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart'; // Import the provider file

class NotificationsPage extends ConsumerWidget {
  // Sample data for notifications
  final List<Map<String, String>> notifications = [
    {
      'title': 'New Job Request: Plumber for Pipe Repair',
      'date': '2024-12-23',
      'details': 'You have received a new job request for a plumber.',
    },
    {
      'title': 'Job Completed: Electrician for Home Wiring',
      'date': '2024-12-20',
      'details': 'The job for an electrician has been marked as completed.',
    },
    {
      'title': 'Payment Received',
      'date': '2024-12-18',
      'details':
          'You have received payment for the job completed on 2024-12-15.',
    },
    {
      'title': 'Job Cancelled: Painter for House Renovation',
      'date': '2024-12-10',
      'details': 'The job for painting has been cancelled by the worker.',
    },
  ];
  Color darkMode = const Color.fromARGB(255, 63, 72, 76);
  NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkColorPro = ref.watch(darkColorProvider);
    final lightColorPro = ref.watch(lightColorProvider);
    return Scaffold(
        appBar: AppBar(
          shape: darkMode == darkColorPro
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(0),
                  ),
                )
              : const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
          title: const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              'Notifications',
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 63, 72, 76),
          centerTitle: true,
        ),
        body: Container(
          color: darkColorPro,
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                color: darkColorPro,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 5,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    notification['title']!,
                    style: TextStyle(
                        color: lightColorPro,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text('Date: ${notification['date']}',
                          style: TextStyle(color: lightColorPro)),
                      const SizedBox(height: 5),
                      Text(
                        notification['details']!,
                        style: TextStyle(color: lightColorPro),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.notifications, color: lightColorPro),
                ),
              );
            },
          ),
        ));
  }
}
