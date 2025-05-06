import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:services/providers.dart';

class JobHistoryPage extends ConsumerStatefulWidget {
  const JobHistoryPage({super.key});

  @override
  ConsumerState<JobHistoryPage> createState() => _JobHistoryPageState();
}

class _JobHistoryPageState extends ConsumerState<JobHistoryPage> {
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
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Define your color variables.
    final darkColorPro = ref.watch(darkColorProvider);
    final lightColorPro = ref.watch(lightColorProvider);
    final lightDarkColorPro = ref.watch(lightDarkColorProvider);
    const darkColor = Color.fromARGB(255, 63, 72, 76);
    // Lighter background color for cards.

    final filteredJobs = _filterStatus == JobStatus.all
        ? _jobs
        : _jobs.where((job) => job.status == _filterStatus).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.white,
        backgroundColor: darkColor,
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(left: 40, bottom: 20),
            child: Text(
              "History",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        shape: darkColor == darkColorPro
            ? const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              )
            : const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
        actions: [
          _buildStatusFilter(darkColorPro, lightColorPro),
        ],
      ),
      backgroundColor: darkColorPro,
      body: Container(
        color: darkColorPro,
        child: _buildBody(filteredJobs, lightColorPro, lightDarkColorPro),
      ),
    );
  }

  Widget _buildBody(
      List<JobHistory> jobs, Color lightColorPro, Color lightDarkColorPro) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (jobs.isEmpty) {
      return Center(
        child: Text(
          'No jobs found',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: lightColorPro.withOpacity(0.8),
              ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _JobCard(
        job: jobs[index],
        lightColorPro: lightColorPro,
        lightDarkColorPro: lightDarkColorPro,
      ),
    );
  }

  Widget _buildStatusFilter(Color darkColorPro, Color lightColorPro) {
    return PopupMenuButton<JobStatus>(
      onSelected: (status) => setState(() => _filterStatus = status),
      itemBuilder: (_) => JobStatus.values.map((status) {
        return PopupMenuItem<JobStatus>(
          value: status,
          child: Row(
            children: [
              Icon(
                status.icon,
                color: status
                    .backgroundColor, // still using status backgroundColor
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                status.label,
                style: TextStyle(color: lightColorPro),
              ),
            ],
          ),
        );
      }).toList(),
      color: darkColorPro,
      icon: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 20),
        child: Icon(
          Icons.filter_list,
          color: lightColorPro,
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobHistory job;
  final Color lightColorPro;
  final Color lightDarkColorPro;

  const _JobCard({
    required this.job,
    required this.lightColorPro,
    required this.lightDarkColorPro,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: lightDarkColorPro,
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
                        color: lightColorPro,
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
              _buildDetailRow(Icons.person, job.client, lightColorPro),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.location_on, job.location, lightColorPro),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailRow(
                    Icons.calendar_today,
                    DateFormat('MMM dd, yyyy • hh:mm a').format(job.date),
                    lightColorPro,
                  ),
                  Text(
                    '\$${job.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: lightColorPro,
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

  Widget _buildDetailRow(IconData icon, String text, Color lightColorPro) {
    return Row(
      children: [
        Icon(icon, size: 16, color: lightColorPro.withValues()),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: lightColorPro,
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
          title: Text(
            job.title,
            style: TextStyle(color: lightColorPro),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Client: ${job.client}',
                  style: TextStyle(color: lightColorPro)),
              Text('Location: ${job.location}',
                  style: TextStyle(color: lightColorPro)),
              Text('Date: ${DateFormat.yMMMd().add_jm().format(job.date)}',
                  style: TextStyle(color: lightColorPro)),
              Text('Status: ${job.status.label}',
                  style: TextStyle(color: lightColorPro)),
              Text('Amount: \$${job.amount.toStringAsFixed(2)}',
                  style: TextStyle(color: lightColorPro)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: lightColorPro),
              ),
            ),
          ],
          backgroundColor: lightDarkColorPro,
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
