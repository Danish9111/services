import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobHistoryPage extends StatefulWidget {
  const JobHistoryPage({Key? key}) : super(key: key);

  @override
  State<JobHistoryPage> createState() => _JobHistoryPageState();
}

class _JobHistoryPageState extends State<JobHistoryPage> {
  final List<JobHistory> _jobs = [
    JobHistory(
      id: '1',
      title: 'Electrical Wiring Installation',
      client: 'John Smith',
      date: DateTime(2024, 3, 15, 14, 30),
      status: JobStatus.completed,
      amount: 450.0,
      location: 'Manhattan, NY',
    ),
    JobHistory(
      id: '2',
      title: 'Emergency Pipe Repair',
      client: 'Sarah Johnson',
      date: DateTime(2024, 3, 14, 9, 15),
      status: JobStatus.inProgress,
      amount: 280.0,
      location: 'Brooklyn, NY',
    ),
    JobHistory(
      id: '3',
      title: 'Commercial Painting Service',
      client: 'Office Solutions Inc.',
      date: DateTime(2024, 3, 12, 16, 0),
      status: JobStatus.cancelled,
      amount: 1200.0,
      location: 'Queens, NY',
    ),
  ];

  JobStatus _filterStatus = JobStatus.all;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _filterStatus == JobStatus.all
        ? _jobs
        : _jobs.where((job) => job.status == _filterStatus).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade600,
        title: const Center(
            child: Padding(
          padding: EdgeInsets.only(left: 40, bottom: 20),
          child: Text(
            "Profile Data",
            style: TextStyle(color: Colors.white),
          ),
        )),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          _buildStatusFilter(),
        ],
      ),
      body: Container(color: Colors.white, child: _buildBody(filteredJobs)),
    );
  }

  Widget _buildBody(List<JobHistory> jobs) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (jobs.isEmpty) {
      return Center(
        child: Text(
          'No jobs found',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _JobCard(job: jobs[index]),
    );
  }

  Widget _buildStatusFilter() {
    return PopupMenuButton<JobStatus>(
        onSelected: (status) => setState(() => _filterStatus = status),
        itemBuilder: (_) => JobStatus.values.map((status) {
              return PopupMenuItem<JobStatus>(
                value: status,
                child: Row(
                  children: [
                    Icon(
                      status.icon,
                      color:
                          status.backgroundColor, // updated from status.color
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(status.label),
                  ],
                ),
              );
            }).toList(),
        icon: const Padding(
          padding: EdgeInsets.only(right: 20, bottom: 20),
          child: Icon(
            Icons.filter_list,
            color: Colors.white,
          ),
        ));
  }
}

class _JobCard extends StatelessWidget {
  final JobHistory job;

  const _JobCard({required this.job, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _showJobDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Chip(
                    backgroundColor: job.status.backgroundColor,
                    label: Text(
                      job.status.label,
                      style: TextStyle(
                        color: job.status.textColor,
                        fontSize: 12,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person, job.client),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.location_on, job.location),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailRow(
                    Icons.calendar_today,
                    DateFormat('MMM dd, yyyy • hh:mm a').format(job.date),
                  ),
                  Text(
                    '\$${job.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showJobDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(job.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Client: ${job.client}'),
              Text('Location: ${job.location}'),
              Text('Date: ${DateFormat.yMMMd().add_jm().format(job.date)}'),
              Text('Status: ${job.status.label}'),
              Text('Amount: \$${job.amount.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Use the parent context via rootNavigator to avoid using a deactivated dialog context
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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

class JobHistory {
  final String id;
  final String title;
  final String client;
  final DateTime date;
  final JobStatus status;
  final double amount;
  final String location;

  JobHistory({
    required this.id,
    required this.title,
    required this.client,
    required this.date,
    required this.status,
    required this.amount,
    required this.location,
  });
}
