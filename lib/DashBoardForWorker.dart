import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'package:services/search_service.dart';
import 'package:services/voiceSearchPage.dart';
import 'ServiceDetails/ServicesDetailPage.dart';
import 'bottomNavigationBar/notification.dart';
import 'drawer/drawerWhole.dart';
import 'providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class Dashboardforworker extends ConsumerStatefulWidget {
  const Dashboardforworker({super.key});

  @override
  DashboardforworkerPageState createState() => DashboardforworkerPageState();
}

class DashboardforworkerPageState extends ConsumerState<Dashboardforworker> {
  late List<Map<String, String>> services = [
    {'title': 'Technician', 'image': 'assets/technician.png'},
    {'title': 'Mechanic', 'image': 'assets/mechanic.png'},
    {'title': 'Electrician', 'image': 'assets/electrician.png'},
    {'title': 'Plumber', 'image': 'assets/plumber.png'},
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
  bool _isBadgeVisible = true;
  int _currentIndex = 0;
  @override
  void initState() {
    _fetchEmail();

    super.initState();
  }

  Future _fetchEmail() async {
    final uID = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('workerProfiles')
        .doc(uID)
        .get()
        .then((DocumentSnapshot snapshot) {
      ref.read(userNameProvider.notifier).state = snapshot.get('name');
      ref.read(userEmailProvider.notifier).state = snapshot.get('phone');
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToServiceDetail(String serviceTitle) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceDetailPage(serviceTitle: serviceTitle),
        ));
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Add navigation logic here if needed
  }

  @override
  Widget build(BuildContext context) {
    // Set light blue status bar color only for this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFB3E5FC), // light blue
        statusBarIconBrightness: Brightness.dark,
      ));
    });
    final darkColorPro = ref.watch(darkColorProvider);
    final lightColorPro = ref.watch(lightColorProvider);
    List<Map<String, String>> filteredServices =
        SearchService.filterServices(services, _searchQuery);

    return Scaffold(
      backgroundColor: darkColorPro,
      appBar: _buildAppBar(lightColorPro),
      drawer: Consumer(
        builder: (context, ref, child) => buildNavigationDrawer(context, ref),
      ),
      body: filteredServices.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                      "Featured Services", context, lightColorPro),
                  _buildHorizontalServiceList(_getFeaturedServices()),
                  _buildSectionHeader("All Categories", context, lightColorPro),
                  _buildServiceGrid(filteredServices),
                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
      // bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar(lightColorPro) {
    final isDark = ref.watch(isDarkProvider);
    // final backgroundColor =
    //     isDark ? const Color.fromARGB(255, 63, 72, 76) : Colors.transparent;
    // final iconColor = isDark ? Colors.white : Colors.black;
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.grey),
      toolbarHeight: 100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      title: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Row(
          children: [
            _buildSearchHeader(isDark),
            _buildNotificationButton(lightColorPro),
            _buildProfileAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(bool isDark) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width * 0.48,
        decoration: BoxDecoration(
          color:
              isDark ? const Color.fromARGB(255, 82, 89, 92) : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? const Color.fromARGB(255, 82, 89, 92)
                : Colors.grey[200],
            hintText: 'Search',
            hintStyle: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(Icons.search_rounded,
                color: isDark ? Colors.white70 : Colors.grey[700]),
            suffixIcon: IconButton(
              icon: Icon(Icons.mic,
                  color: isDark ? Colors.white70 : Colors.grey[700]),
              onPressed: () => _showVoiceSearch(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  void _showVoiceSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const VoiceSearchBottomSheet(),
    ).then((searchQuery) {
      if (searchQuery != null && searchQuery.toString().isNotEmpty) {
        setState(() {
          services =
              SearchService.filterServices(services, searchQuery.toString());
        });
      }
    });
  }

  Widget _buildSectionHeader(
      String title, BuildContext context, Color lightColorPro) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightColorPro,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHorizontalServiceList(List<Map<String, String>> services) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: services.length,
        itemBuilder: (context, index) =>
            _buildFeaturedServiceCard(services[index], index),
      ),
    );
  }

  Widget _buildFeaturedServiceCard(Map<String, String> service, int index) {
    final colors = [
      [Colors.blue.shade100, Colors.blue.shade200],
      [Colors.green.shade100, Colors.green.shade200],
      [Colors.orange.shade100, Colors.orange.shade200],
      [Colors.purple.shade100, Colors.purple.shade200],
      [Colors.teal.shade100, Colors.teal.shade200],
    ];

    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors[index % colors.length],
        ),
        boxShadow: [
          BoxShadow(
            color: colors[index % colors.length].first.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToServiceDetail(service['title']!),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    service['image']!,
                    width: 40,
                    height: 40,
                  ),
                ),
                Text(
                  service['title']!,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGrid(List<Map<String, String>> services) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) =>
          _buildServiceCard(services[index], index),
    );
  }

  Widget _buildServiceCard(Map<String, String> service, int index) {
    final colors = [
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.orange.shade50,
      Colors.purple.shade50,
      Colors.teal.shade50,
      Colors.pink.shade50,
      Colors.amber.shade50,
      Colors.indigo.shade50,
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _navigateToServiceDetail(service['title']!),
        child: Container(
          decoration: BoxDecoration(
            color: colors[index % colors.length],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  service['image']!,
                  width: 50,
                  height: 50,
                ),
                const SizedBox(height: 12),
                Text(
                  service['title']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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

  Widget _buildNotificationButton(Color lightColorPro) {
    final notificationStream = FirebaseFirestore.instance
        .collection('task')
        .where('status', isEqualTo: 'pending')
        .where('professionalId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    notificationStream.listen((snapshot) {
      ref.read(notificationCountProvider.notifier).state = snapshot.docs.length;
    });

    final badgeCount = ref.watch(notificationCountProvider);
    if (badgeCount == 0) {
      _isBadgeVisible = false;
    } else {
      _isBadgeVisible = true;
    }
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 0, end: 5),
      badgeContent: Text(badgeCount.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 10)),
      badgeColor: Colors.red.shade400,
      showBadge: _isBadgeVisible,
      child: IconButton(
        icon: Icon(Icons.notifications_none_rounded, color: lightColorPro),
        onPressed: () {
          setState(() => _isBadgeVisible = false);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NotificationsPage()));
        },
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final imageUrl = ref.watch(profileImageProvider);
    return Padding(
      padding: const EdgeInsets.only(left: 12), // Move image a bit to the right
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.blueGrey.shade800,
        child: Builder(
          builder: (_) {
            try {
              if (imageUrl != null && imageUrl.isNotEmpty) {
                if (imageUrl.startsWith('http')) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(imageUrl),
                  );
                } else {
                  return CircleAvatar(
                    radius: 20,
                    backgroundImage: FileImage(File(imageUrl)),
                  );
                }
              } else {
                return const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/default_pic.png'),
                );
              }
            } catch (e) {
              debugPrint('❌Error loading profile avatar: $e');
              return const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/profile_pic.jpeg'),
              );
            }
          },
        ),
      ),
    );
  }

  List<Map<String, String>> _getFeaturedServices() =>
      services.sublist(0, services.length < 5 ? services.length : 5);
}
