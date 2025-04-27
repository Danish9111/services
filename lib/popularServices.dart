import 'package:flutter/material.dart';
import 'ServiceDetails/ServicesDetailPage.dart';

class PopularServices extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {
      'title': 'Electrician',
      'icon': Icons.electrical_services,
      'color': Colors.blue.shade200
    },
    {
      'title': 'Plumber',
      'icon': Icons.plumbing,
      'color': Colors.green.shade200
    },
    {
      'title': 'Carpenter',
      'icon': Icons.handyman,
      'color': Colors.orange.shade200
    },
    {
      'title': 'Painter',
      'icon': Icons.format_paint,
      'color': Colors.purple.shade200
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ServiceDetailPage(serviceTitle: service['title']),
                ),
              );
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: service['color'],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(service['icon'], size: 40, color: Colors.black87),
                  SizedBox(height: 8),
                  Text(
                    service['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
