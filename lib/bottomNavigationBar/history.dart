import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:services/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobHistoryPage extends ConsumerStatefulWidget {
  const JobHistoryPage({super.key});

  @override
  ConsumerState<JobHistoryPage> createState() => _JobHistoryPageState();
}

class _JobHistoryPageState extends ConsumerState<JobHistoryPage> {
  List<JobHistory> _jobs = [];
  JobStatus _filterStatus = JobStatus.all;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobsFromFirestore();
  }

  Future<void> _fetchJobsFromFirestore() async {
    setState(() {
      _isLoading = true;
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // if (uid == null) return;
    if (uid == null) return;

    final taskSnapshot = await FirebaseFirestore.instance
        .collection('task')
        .where('professionalId', isEqualTo: uid)
        .get();

    final jobs = await Future.wait(taskSnapshot.docs.map((doc) async {
      final data = doc.data();
      // Fetch sender info
      String senderName = '';
      String senderAddress = '';
      if (data['employerId'] != null) {
        final senderDoc = await FirebaseFirestore.instance
            .collection('workerProfiles')
            .doc(data['employerId'])
            .get();
        final senderData = senderDoc.data();
        senderName = senderData?['name'] ?? '';
        senderAddress = senderData?['location'] ?? '';
      }
      return JobHistory(
        id: doc.id,
        title: data['taskDetails'] ?? 'No Title',
        client: senderName,
        date: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: _mapStatus(data['status']),
        // amount: (data['amount'] ?? 0).toDouble(),
        senderAddress: senderAddress,
      );
    }).toList());
    setState(() {
      _jobs = jobs;
      _isLoading = false;
    });
  }

  JobStatus _mapStatus(String? status) {
    switch (status) {
      case 'completed':
        return JobStatus.completed;
      case 'inProgress':
        return JobStatus.inProgress;
      case 'cancelled':
        return JobStatus.cancelled;
      case 'acceptedByWorker':
        return JobStatus.acceptedByWorker;
      case 'rejectedByWorker':
        return JobStatus.rejectedByWorker;
      default:
        return JobStatus.all;
    }
  }

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

    // Use StreamBuilder for real-time updates
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('task')
          .where('professionalId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No jobs found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: lightColorPro.withOpacity(0.8),
                  ),
            ),
          );
        }
        final docs = snapshot.data!.docs;
        return FutureBuilder<List<JobHistory>>(
          future: Future.wait(docs.map((doc) async {
            final data = doc.data() as Map<String, dynamic>;
            String senderName = '';
            String senderAddress = '';
            if (data['employerId'] != null) {
              final senderDoc = await FirebaseFirestore.instance
                  .collection('workerProfiles')
                  .doc(data['employerId'])
                  .get();
              final senderData = senderDoc.data();
              senderName = senderData?['name'] ?? '';
              senderAddress = senderData?['location'] ?? '';
            }
            return JobHistory(
              id: doc.id,
              title: data['taskDetails'] ?? 'No Title',
              client: senderName,
              date:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              status: _mapStatus(data['status']),
              // amount: (data['amount'] ?? 0).toDouble(),
              senderAddress: senderAddress,
            );
          }).toList()),
          builder: (context, jobSnapshot) {
            if (!jobSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final jobs = _filterStatus == JobStatus.all
                ? jobSnapshot.data!
                : jobSnapshot.data!
                    .where((job) => job.status == _filterStatus)
                    .toList();
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
          },
        );
      },
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

// enum JobStatus {
//   all('All', Icons.all_inclusive, Colors.grey, Colors.grey),
//   completed('Completed', Icons.check_circle, Colors.green, Colors.white),
//   inProgress('In Progress', Icons.access_time, Colors.orange, Colors.white),
//   cancelled('Cancelled', Icons.cancel, Colors.red, Colors.white),
//   acceptedByWorker('Accepted', Icons.verified, Colors.green, Colors.white),
//   rejectedByWorker('Rejected', Icons.cancel, Colors.red, Colors.white);

//   final String label;
//   final IconData icon;
//   final Color backgroundColor;
//   final Color textColor;

//   const JobStatus(
//     this.label,
//     this.icon,
//     this.backgroundColor,
//     this.textColor,
//   );
// }
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
    final isAccepted = job.status == JobStatus.acceptedByWorker;
    final isRejected = job.status == JobStatus.rejectedByWorker;

    if (isAccepted) {
      // Detailed card for accepted job/task offer
      return Card(
        color: Colors.green.shade50,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showJobDetails(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                    Icon(Icons.verified,
                        color: Colors.green.shade700, size: 28),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDetailRow(Icons.person, 'Sender: ${job.client}',
                    Colors.green.shade900),
                if (job.senderAddress.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.home, 'Address: ${job.senderAddress}',
                      Colors.green.shade900),
                ],
                const SizedBox(height: 8),
                _buildDetailRow(
                    Icons.calendar_today,
                    DateFormat('MMM dd, yyyy • hh:mm a').format(job.date),
                    Colors.green.shade900),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Chip(
                      backgroundColor: Colors.grey,
                      label: Text(
                        'You Accepted this',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    OutlinedButton(
                        onPressed: () => updateStatusToDone(context),
                        child: const Text('Mark it Done ✅'))
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isRejected) {
      // Detailed card for rejected job/task offer
      return Card(
        color: Colors.red.shade50,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showJobDetails(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                    Icon(Icons.cancel, color: Colors.red.shade700, size: 28),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                    Icons.person, 'Sender: ${job.client}', Colors.red.shade900),
                if (job.senderAddress.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.home, 'Address: ${job.senderAddress}',
                      Colors.red.shade900),
                ],
                const SizedBox(height: 8),
                _buildDetailRow(
                    Icons.calendar_today,
                    DateFormat('MMM dd, yyyy • hh:mm a').format(job.date),
                    Colors.red.shade900),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      backgroundColor: Colors.grey,
                      label: Text(' You Rejected this',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                  Icon(
                    job.status.icon,
                    color: job.status.backgroundColor,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (job.senderAddress.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildDetailRow(
                  Icons.home,
                  job.senderAddress,
                  lightColorPro,
                ),
              ],
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person, job.client, lightColorPro),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailRow(
                    Icons.calendar_today,
                    DateFormat('MMM dd, yyyy • hh:mm a').format(job.date),
                    lightColorPro,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14,
                      color: job.status.textColor,
                      fontWeight: FontWeight.w600,
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

  Future<void> updateStatusToDone(BuildContext context) async {
    try {
      FirebaseFirestore.instance.collection('task').doc(job.id).update({
        'status': 'done',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully marked as done'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              Text('Date: ${DateFormat.yMMMd().add_jm().format(job.date)}',
                  style: TextStyle(color: lightColorPro)),
              Text('Status: ${job.status.label}',
                  style: TextStyle(color: lightColorPro)),
              // Text('Amount: \$${job.amount.toStringAsFixed(2)}',
              // style: TextStyle(color: lightColorPro)),
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
  cancelled('Cancelled', Icons.cancel, Colors.red, Colors.white),
  acceptedByWorker('Accepted', Icons.verified, Colors.green, Colors.white),
  rejectedByWorker('Rejected', Icons.cancel, Colors.red, Colors.white);

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
  // final double amount;
  final String senderAddress;

  JobHistory({
    required this.id,
    required this.title,
    required this.client,
    required this.date,
    required this.status,
    // required this.amount,
    required this.senderAddress,
  });
}
