import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
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
      'details': 'You have received payment for the job completed on 2024-12-15.',
    },
    {
      'title': 'Job Cancelled: Painter for House Renovation',
      'date': '2024-12-10',
      'details': 'The job for painting has been cancelled by the worker.',
    },
  ];

  NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 5,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                notification['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text('Date: ${notification['date']}'),
                  const SizedBox(height: 5),
                  Text(notification['details']!),
                ],
              ),
              trailing: const Icon(Icons.notifications, color: Colors.blueAccent),
            ),
          );
        },
      ),
    );
  }
}
