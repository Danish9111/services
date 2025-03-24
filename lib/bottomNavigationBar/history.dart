import 'package:flutter/material.dart';

class JobHistoryPage extends StatefulWidget {
  @override
  JobHistoryPageState createState() => JobHistoryPageState();
  // final int selectedIndex;
  // final Function(int) onItemTapped;

  const JobHistoryPage({
    super.key,
  });
}

class JobHistoryPageState extends State<JobHistoryPage> {
  final int _selectedIndex = 0;

  // Sample data for job history
  final List<Map<String, String>> jobHistory = [
    {
      'jobTitle': 'Electrician for Home Wiring',
      'date': '2024-12-20',
      'status': 'Completed',
    },
    {
      'jobTitle': 'Plumber for Pipe Repair',
      'date': '2024-12-18',
      'status': 'In Progress',
    },
    {
      'jobTitle': 'Driver for Transporting Goods',
      'date': '2024-12-15',
      'status': 'Completed',
    },
    {
      'jobTitle': 'Painter for House Renovation',
      'date': '2024-12-10',
      'status': 'Cancelled',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job History'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: jobHistory.length,
        itemBuilder: (context, index) {
          final job = jobHistory[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 5,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                job['jobTitle']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text('Date: ${job['date']}'),
                  const SizedBox(height: 5),
                  Text('Status: ${job['status']}'),
                ],
              ),
              trailing: _buildStatusIcon(job['status']!),
            ),
          );
        },
      ),
      // bottomNavigationBar: CustomBottomNavBar(
      //   selectedIndex: 0,
      // ),
    );
  }

  // Function to show an icon based on job status
  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'In Progress':
        return const Icon(Icons.access_time, color: Colors.orange);
      case 'Cancelled':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}
