import 'package:services/search_service.dart';
import 'package:services/voiceSearchPage.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

import 'ServiceDetails/ServicesDetailPage.dart';
import 'bottomNavigationBar/notification.dart';
import 'drawer/drawerWhole.dart';

class Dashboardforworker extends StatefulWidget {
  const Dashboardforworker({super.key});

  @override
  DashboardforworkerPageState createState() => DashboardforworkerPageState();
}

class DashboardforworkerPageState extends State<Dashboardforworker> {
  // List of services with title and image.
  late List<Map<String, String>> services = [
    {'title': 'Technician', 'image': 'assets/technician.png'},
    {'title': 'Mechanic', 'image': 'assets/mechanic.png'},
    {'title': 'Electrician', 'image': 'assets/electrician.png'},
    {'title': 'plumber', 'image': 'assets/plumber.png'},
    {'title': 'Driver', 'image': 'assets/driver.png'},
    {'title': 'Painter', 'image': 'assets/painter.png'},
    {'title': 'Mason', 'image': 'assets/mason.png'},
    {'title': 'Tailor', 'image': 'assets/tailor.png'},
    {'title': 'Barber', 'image': 'assets/barber.png'},
    {'title': 'Gardener', 'image': 'assets/gardenerr.png'},
    {'title': 'Welder', 'image': 'assets/welder.png'},
    {'title': 'Carpenter', 'image': 'assets/carpenter.png'},
    {'title': 'Cleaner', 'image': 'assets/cleaning-staff.png'},
    {'title': 'Chef', 'image': 'assets/chef.png'},
    {'title': 'Security Guard', 'image': 'assets/security.png'},
    {'title': 'Delivery', 'image': 'assets/person.png'},
  ];

  String _searchQuery = '';

  /// Update search query when user types
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  /// Navigate to the service detail page.
  void _navigateToServiceDetail(String serviceTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailPage(serviceTitle: serviceTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter services based on search query.
    List<Map<String, String>> filteredServices =
        SearchService.filterServices(services, _searchQuery);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      drawer: buildNavigationDrawer(context),
      body: Column(
        children: [
          Expanded(
            child: filteredServices.isEmpty
                ? _buildEmptyState()
                : _buildServiceGrid(filteredServices),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: Colors.lightBlue.shade50,
      elevation: 4,
      shadowColor: Colors.lightBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      title: Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(children: [
            _buildSearchHeader(),
            _buildNotificationButton(),
            _buildProfileAvatar(),
            // Search bar inside the AppBar
          ]),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.05,
      width: screenWidth * 0.48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 210, 210, 210),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search',
          hintStyle: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.blueGrey.shade400,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const VoiceSearchBottomSheet(),
              ).then((searchQuery) {
                if (searchQuery != null && searchQuery.toString().isNotEmpty) {
                  final filteredServices = SearchService.filterServices(
                      services, searchQuery.toString());

                  setState(() {
                    services = filteredServices;
                  });
                }
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildServiceGrid(List<Map<String, String>> services) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) => _buildServiceCard(services[index]),
        );
      },
    );
  }

  Widget _buildServiceCard(Map<String, String> service) {
    return Card(
      elevation: 0, // Increased elevation for better depth
      margin: const EdgeInsets.all(2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Slightly larger radius
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _navigateToServiceDetail(service['title']!),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 234, 234, 234),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding:
                        EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          service['image']!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.handyman_rounded,
                            size: 30,
                            color: Colors.blue.shade300,
                          ),
                        ),
                        // Optional shimmer effect while loading
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  service['title']!,
                  style: const TextStyle(
                    fontSize: 16, // Slightly smaller font
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(20),
                //     color: const Color.fromARGB(255, 0, 152, 194),
                //   ),
                //   child: const Row(
                //     mainAxisSize: MainAxisSize.min,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         'View Services ',
                //         style: TextStyle(
                //           fontSize: 11, // Smaller font size
                //           color: Colors.white,
                //           fontWeight: FontWeight.w600,
                //           letterSpacing: 0.2,
                //         ),
                //       ),
                //       SizedBox(width: 4),
                //       Icon(
                //         Icons.arrow_forward_rounded,
                //         size: 14, // Smaller icon size
                //         color: Colors.white,
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.blueGrey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Services Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Try adjusting your search terms or browse through our main categories',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isBadgeVisible = true;

  Widget _buildNotificationButton() {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 0, end: 5),
      badgeContent:
          const Text('3', style: TextStyle(color: Colors.white, fontSize: 10)),
      badgeColor: Colors.red.shade400,
      showBadge: _isBadgeVisible,
      child: IconButton(
        icon: Icon(
          Icons.notifications_none_rounded,
          color: Colors.blueGrey.shade600,
        ),
        onPressed: () {
          setState(() {
            _isBadgeVisible = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationsPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.blueGrey.shade800,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/profile_pic.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
