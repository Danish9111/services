import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workerProfileForm.dart';
import 'package:services/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:path_provider/path_provider.dart';
import '../messaging/customeLoader.dart';
import 'package:services/ServiceDetails/serviceCompletionCard.dart';

File? _imageFile;

class EmployerProfile extends ConsumerStatefulWidget {
  const EmployerProfile({super.key});

  @override
  ConsumerState<EmployerProfile> createState() => _EmployerProfileState();
}

class _EmployerProfileState extends ConsumerState<EmployerProfile> {
  bool isEmployer = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? publicUrl;
  User? user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Map<String, String> employerData = {
    'name': '',
    'email': '',
    'phone': '',
    'location': '',
    'jobTitle': '',
    'role': '',
    'about': '',
    'type': ''
  };

  Map<String, String> workerData = {
    'name': '',
    'email': '',
    'phone': '',
    'location': '',
    'jobTitle': '',
    'role': '',
    'about': '',
    'type': ''
  };

  final List<String> allRoles = [
    'Technician',
    'Mechanic',
    'Electrician',
    'Plumber',
    'Driver',
    'Painter',
    'Mason',
    'Tailor',
    'Barber',
    'Gardener',
    'Welder',
    'Carpenter',
    'Cleaner',
    'Chef',
    'Security Guard',
    'Delivery',
  ];

  Future<void> _loadProfileData() async {
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    bool loadedFromCache = false;
    try {
      // Try loading from cache first
      final cachedEmail = prefs.getString('profile_email_$uid');
      final cachedPhone = prefs.getString('profile_phone_$uid');
      final cachedLocation = prefs.getString('profile_location_$uid');
      final cachedAbout = prefs.getString('profile_about_$uid');
      if (cachedEmail != null &&
          cachedPhone != null &&
          cachedLocation != null &&
          cachedAbout != null) {
        setState(() {
          workerData['email'] = cachedEmail;
          workerData['phone'] = cachedPhone;
          workerData['location'] = cachedLocation;
          workerData['about'] = cachedAbout;
        });
        loadedFromCache = true;
      }
      // Always fetch from Firestore at least once to update cache if needed
      DocumentSnapshot workerDoc = await FirebaseFirestore.instance
          .collection('workerProfiles')
          .doc(uid)
          .get();
      if (workerDoc.exists) {
        final data =
            Map<String, dynamic>.from(workerDoc.data() as Map<String, dynamic>);
        setState(() {
          workerData = Map<String, String>.from(
              data.map((k, v) => MapEntry(k, v?.toString() ?? '')));
        });
        // Update cache if values are present
        if (data['email'] != null) {
          await prefs.setString('profile_email_$uid', data['email']);
        }
        if (data['phone'] != null) {
          await prefs.setString('profile_phone_$uid', data['phone']);
        }
        if (data['location'] != null) {
          await prefs.setString('profile_location_$uid', data['location']);
        }
        if (data['about'] != null) {
          await prefs.setString('profile_about_$uid', data['about']);
        }
      }
      // Check and load employer profile data.
      DocumentSnapshot employerDoc = await FirebaseFirestore.instance
          .collection('employerProfiles')
          .doc(uid)
          .get();

      if (employerDoc.exists) {
        setState(() {
          employerData = (employerDoc.data() as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v?.toString() ?? ''));
        });
      }

      // Similarly, load worker profile data if needed.
      DocumentSnapshot workerDocs = await FirebaseFirestore.instance
          .collection('workerProfiles')
          .doc(uid)
          .get();

      if (workerDocs.exists) {
        setState(() {
          workerData = (workerDocs.data() as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v?.toString() ?? ''));
        });
      }

      // Update controllers with fetched data.
      _updateControllers();
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  Map<String, String> get activeProfileData =>
      isEmployer ? employerData : workerData;

  // Form key for validation.
  final _formKey = GlobalKey<FormState>();

  // Controllers for editable fields.
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _roleController;
  late TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    // reloadProfileImageForCurrentUser();
    _loadProfileData();
    // Load image from SharedPreferences if available
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // reloadProfileImageForCurrentUser();

      debugPrint("User ID: ${firebaseUser.uid}");
    } else {
      debugPrint("User not authenticated");
    }

    // Initialize controllers with current profile data.
    _nameController = TextEditingController(text: activeProfileData['name']);
    _emailController = TextEditingController(text: activeProfileData['email']);
    _phoneController = TextEditingController(text: activeProfileData['phone']);
    _locationController =
        TextEditingController(text: activeProfileData['location']);
    _roleController = TextEditingController(text: activeProfileData['role']);
    _aboutController = TextEditingController(text: activeProfileData['about']);
    // _loadLocalProfileImage();
  }

  // Future<void> _loadLocalProfileImage() async {
  //   if (uid == null) {
  //     setState(() {
  //       _imageFile = null;
  //     });
  //     ref.read(profileImageProvider.notifier).state = '';
  //     return;
  //   }
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? imagePath = prefs.getString('profile_image_path_$uid');
  //   setState(() {
  //     _imageFile =
  //         (imagePath != null && imagePath.isNotEmpty) ? File(imagePath) : null;
  //   });
  //   // ref.read(profileImageProvider.notifier).state = imagePath ?? '';
  // }

  // Call this after login/logout/account switch to always load the correct image
  // Future<void> reloadProfileImageForCurrentUser() async {
  //   if (uid == null) {
  //     setState(() {
  //       _imageFile = null;
  //     });
  //     ref.read(profileImageProvider.notifier).state = '';
  //     return;
  //   }
  //   String reaction = '';
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? imagePath = prefs.getString('profile_image_path_$uid');
  //   setState(() {
  //     reaction = '❤️❤️';
  //     _imageFile =
  //         (imagePath != null && imagePath.isNotEmpty) ? File(imagePath) : null;
  //   });
  //   debugPrint('your code is running $reaction');

  //   ref.read(profileImageProvider.notifier).state = imagePath ?? '';
  // }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _roleController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  // Updates controllers when switching profile types.
  void _updateControllers() {
    _nameController.text = activeProfileData['name']!;
    _emailController.text = activeProfileData['email']!;
    _phoneController.text = activeProfileData['phone']!;
    _locationController.text = activeProfileData['location']!;
    _roleController.text = activeProfileData['role']!;
    _aboutController.text = activeProfileData['about']!;
  }

  @override
  Widget build(BuildContext context) {
    final darkColorPro = ref.watch(darkColorProvider);
    final lightColorPro = ref.watch(lightColorProvider);
    const darkColor = Color.fromARGB(255, 63, 72, 76);
    final imageUrl = ref.watch(profileImageProvider);
    return Scaffold(
      backgroundColor: darkColorPro,
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              "Profile Data",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 72, 76),
      ),
      body: Stack(
        children: [
          Container(
            color: darkColorPro,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfileHeader(lightColorPro, darkColorPro),
                      const SizedBox(height: 10),
                      _buildRoleSwitchCard(lightColorPro, darkColorPro),
                      const SizedBox(height: 10),
                      _buildInfoSection(lightColorPro, darkColorPro),
                      const SizedBox(height: 20),
                      _buildActionButtons(lightColorPro, darkColorPro),
                      if (_isEditing)
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('workerProfiles')
                              .doc(uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return const SizedBox.shrink();
                            }
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final experience =
                                data['experience']?.toString() ?? '';
                            final fee = data['fee']?.toString() ?? '';
                            final availability =
                                data['availability']?.toString() ?? '';
                            final missingFields = <String>[];
                            if (experience.isEmpty)
                              missingFields.add('Experience');
                            if (fee.isEmpty) missingFields.add('Fee');
                            if (availability.isEmpty)
                              missingFields.add('Availability');
                            if (missingFields.isEmpty)
                              return const SizedBox.shrink();
                            return Container(
                              margin: const EdgeInsets.only(top: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                border: Border.all(color: Colors.orangeAccent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Profile completion',
                                              style: TextStyle(
                                                color: Colors.orange.shade900,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Add the following to complete your professional profile: '
                                              '${missingFields.join(', ')}',
                                              style: TextStyle(
                                                color: Colors.orange.shade900,
                                                fontSize: 14,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orangeAccent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        _showCompleteProfileModal(
                                            missingFields);
                                      },
                                      icon: const Icon(
                                          Icons.check_circle_outline_sharp,
                                          color: Colors.white,
                                          opticalSize: 20),
                                      label: const Text('Complete Profile'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const CustomLoader(),
            ),
        ],
      ),
    );
  }

  // ---------------------------
  // UI Building Methods
  // ---------------------------
  Widget _buildProfileHeader(Color lightColorPro, Color darkColorPro) {
    final imageUrl = ref.watch(profileImageProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: lightColorPro, width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: darkColorPro,
            child: Stack(
              children: [
                ClipOval(
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? (imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.person,
                                color: lightColorPro,
                                size: 50,
                              ),
                            )
                          : Image.file(
                              File(imageUrl),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.person,
                                color: lightColorPro,
                                size: 50,
                              ),
                            ))
                      : IconButton(
                          icon: Icon(
                            Icons.person,
                            color: lightColorPro,
                            size: 50,
                          ),
                          onPressed: () async {
                            File? pickedImage = await _pickPhoto();
                            if (pickedImage != null) {
                              setState(() {
                                _imageFile = pickedImage;
                              });
                            }
                          },
                        ),
                ),
                if (_isEditing && imageUrl != null && imageUrl.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _removeProfileImage,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        _isEditing
            ? TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: lightColorPro),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightColorPro),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Name cannot be empty"
                    : null,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: lightColorPro,
                ),
              )
            : Text(
                activeProfileData['name']?.isNotEmpty == true
                    ? activeProfileData['name']!
                    : "No Name",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: lightColorPro,
                ),
              ),
        const SizedBox(height: 5),
        _isEditing
            ? DropdownButtonFormField<String>(
                value: allRoles.contains(_roleController.text) &&
                        _roleController.text.isNotEmpty
                    ? _roleController.text
                    : null,
                items: allRoles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Row(
                      children: [
                        Icon(Icons.work_outline,
                            color: lightColorPro, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          role,
                          style: TextStyle(
                            color: lightColorPro,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _roleController.text = value ?? '';
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: lightColorPro),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightColorPro),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightColorPro),
                  ),
                ),
                dropdownColor: darkColorPro,
                icon: Icon(Icons.arrow_drop_down, color: lightColorPro),
                style: TextStyle(
                  fontSize: 18,
                  color: lightColorPro,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Text(
                activeProfileData['role']?.isNotEmpty == true
                    ? activeProfileData['role']!
                    : "No Role",
                style: TextStyle(
                  fontSize: 18,
                  color: lightColorPro,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
      ],
    );
  }

  File? pickedImage;
  Future<File?> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final tempImage = File(picked.path);
    final prefs = await SharedPreferences.getInstance();
    File savedImage = tempImage;

    if (uid != null) {
      final appDir = await getApplicationDocumentsDirectory();
      savedImage = await tempImage
          .copy('${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await prefs.setString('profile_image_path_$uid', savedImage.path);
    } else {
      await prefs.setString('profile_image_path_temp', tempImage.path);
    }
    final savedImageis = savedImage.path;
    debugPrint('😊the path from pick photo function savedImage: $savedImageis');

    ref.read(profileImageProvider.notifier).state = savedImage.path;

    setState(() {
      _imageFile = savedImage;
      pickedImage = savedImage;
    });

    return savedImage;
  }

  void _removeProfileImage() async {
    setState(() {
      _imageFile = null;
    });
    if (uid != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_path_$uid');
      ref.read(profileImageProvider.notifier).state = '';
    }
  }

  Future<void> _putImageToSupabaseStorage(File imageFile) async {
    final supabase = sb.Supabase.instance.client;
    if (uid == null) return; // safety first

    try {
      // 1. uploadBinary → returns the path or throws on network/storage errors
      final filePath =
          await supabase.storage.from('profileimages').uploadBinary(
                'uploads/$uid.jpg',
                await imageFile.readAsBytes(),
                fileOptions: const sb.FileOptions(upsert: true),
              );

      if (filePath.isEmpty) throw Exception('Empty upload path');
      debugPrint('rawPath → $filePath');
// 2. getPublicUrl → synchronous String
      publicUrl = supabase.storage
          .from('profileimages')
          .getPublicUrl('uploads/$uid.jpg');

// Bust cache by appending timestamp
      final cacheBustedUrl =
          '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';
      try {
        // Update provider and SharedPreferences with cache-busted URL
        ref.read(profileImageProvider.notifier).state = cacheBustedUrl;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path_$uid', cacheBustedUrl);
        debugPrint('😊 Profile image URL updated: $cacheBustedUrl');
      } catch (e) {
        debugPrint('❌ Error updating provider or prefs: $e');
      }

      try {
        await FirebaseFirestore.instance
            .collection('employerProfiles')
            .doc(uid)
            .update({'senderImageUrl': cacheBustedUrl});
      } catch (e) {
        debugPrint('❌ Error uploading profile image url to  Firestore: $e');
      }

      // Clear local image state after upload
      setState(() {
        pickedImage = null;
        _imageFile = null;
      });
    } on sb.PostgrestException catch (e) {
      // catches RLS / HTTP / Postgrest errors
      debugPrint('❌ Supabase error: \\${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Supabase error: \\${e.message}')),
      );
    } catch (e) {
      // catches any other errors (e.g. file IO)
      debugPrint('🔥 Unexpected error: \\$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: \\$e')),
      );
    }
  }

  Widget _buildRoleSwitchCard(Color lightColorPro, Color darkColorPro) {
    return Card(
      color: darkColorPro,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: lightColorPro, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Mode:',
              style: TextStyle(
                fontSize: 16,
                color: lightColorPro,
                fontWeight: FontWeight.w500,
              ),
            ),
            IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ScaleTransition(
                    scale: AlwaysStoppedAnimation(isEmployer ? 1.0 : 0.9),
                    child: Text(
                      isEmployer ? 'Employer' : 'Worker',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: lightColorPro,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: -0.1,
                    child: Opacity(
                      opacity: 0.8,
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          'assets/brush_stroke.png',
                          height: 8,
                          fit: BoxFit.fitWidth,
                          color: Colors.green.shade600.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(Color lightColorPro, Color darkColorPro) {
    return Column(
      children: [
        _buildEditableEmailField(
          icon: Icons.email,
          label: 'Email',
          controller: _emailController,
          validatorMsg: "Email cannot be empty",
          lightColorPro: lightColorPro,
          darkColorPro: darkColorPro,
        ),
        _buildEditableField(
          icon: Icons.phone,
          label: 'Contact',
          controller: _phoneController,
          validatorMsg: "Phone number cannot be empty",
          lightColorPro: lightColorPro,
          darkColorPro: darkColorPro,
        ),
        _buildEditableField(
          icon: Icons.location_on,
          label: 'Location',
          controller: _locationController,
          validatorMsg: "Location cannot be empty",
          lightColorPro: lightColorPro,
          darkColorPro: darkColorPro,
        ),
        const SizedBox(height: 10),
        _buildAboutCard(lightColorPro, darkColorPro),
      ],
    );
  }

  Widget _buildEditableEmailField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    String? validatorMsg,
    required Color lightColorPro,
    required Color darkColorPro,
  }) {
    return ListTile(
      leading: Icon(icon, color: lightColorPro),
      title: _isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: lightColorPro),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightColorPro)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email cannot be empty";
                }
                final emailRegex =
                    RegExp(r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
                if (!emailRegex.hasMatch(value)) {
                  return "Please enter a valid email address";
                }
                return null;
              },
            )
          : Text(
              controller.text,
              style: TextStyle(fontSize: 16, color: lightColorPro),
            ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    String? validatorMsg,
    required Color lightColorPro,
    required Color darkColorPro,
  }) {
    return ListTile(
      leading: Icon(icon, color: lightColorPro),
      title: _isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: lightColorPro),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lightColorPro)),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? validatorMsg : null,
            )
          : Text(
              controller.text,
              style: TextStyle(fontSize: 16, color: lightColorPro),
            ),
    );
  }

  Widget _buildAboutCard(Color lightColorPro, Color darkColorPro) {
    final lightDarkColorPro = ref.watch(lightDarkColorProvider);
    final isDark = ref.watch(isDarkProvider);
    return Card(
      color: isDark ? lightDarkColorPro : Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline,
                    color: isDark
                        ? Colors.white
                        : const Color.fromARGB(255, 63, 72, 76)),
                const SizedBox(width: 8),
                Text(
                  'About ${activeProfileData['type']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white
                        : const Color.fromARGB(255, 63, 72, 76),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _isEditing
                ? TextFormField(
                    controller: _aboutController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'About',
                      labelStyle: TextStyle(color: lightColorPro),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: lightColorPro)),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "About cannot be empty"
                        : null,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 63, 72, 76),
                      height: 1.4,
                    ),
                  )
                : Text(
                    activeProfileData['about']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? Colors.white
                          : const Color.fromARGB(255, 63, 72, 76),
                      height: 1.4,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Color lightColorPro, Color darkColorPro) {
    final isDark = ref.watch(isDarkProvider);
    return Column(
      children: [
        _isEditing
            ? ElevatedButton.icon(
                icon: Icon(Icons.save, color: lightColorPro),
                label: Text(
                  'Save Profile',
                  style: TextStyle(color: lightColorPro),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkColorPro,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saveProfile,
              )
            : ElevatedButton.icon(
                icon: Icon(Icons.edit,
                    color: isDark
                        ? const Color.fromARGB(255, 63, 72, 76)
                        : Colors.white),
                label: Text(
                  'Edit Profile',
                  style: TextStyle(
                      color: isDark
                          ? const Color.fromARGB(255, 63, 72, 76)
                          : Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  isEmployer
                      ? ref.read(userProfileProvider.notifier).state =
                          'employer'
                      : 'worker';
                  setState(() {
                    _isEditing = true;
                  });
                  _updateControllers();

                  // Check for missing fields and show modal if needed
                  final data = workerData;
                  final experience = data['experience']?.toString() ?? '';
                  final fee = data['fee']?.toString() ?? '';
                  final availability = data['availability']?.toString() ?? '';
                  final missingFields = <String>[];
                  if (experience.isNotEmpty) missingFields.add('Experience');
                  if (fee.isNotEmpty) missingFields.add('Fee');
                  if (availability.isNotEmpty)
                    missingFields.add('Availability');
                  if (missingFields.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showCompleteProfileModal(missingFields);
                    });
                  }
                },
              ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: Icon(Icons.swap_horiz, color: lightColorPro),
          label: Text(
            'Switch to ${isEmployer ? 'Worker' : 'Employer'} Profile',
            style: TextStyle(color: lightColorPro),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
            side: BorderSide(color: lightColorPro),
          ),
          onPressed: _toggleProfileType,
        ),
      ],
    );
  }

  void _showCompleteProfileModal(List<String> missingFields) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // Controllers for text fields
    final feeController = TextEditingController();
    // State variables for pickers
    int? selectedExperience;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    final List<String> selectedDays = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 16,
                  right: 16,
                  top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Complete Profile',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(),
                  if (missingFields.contains('Experience')) ...[
                    const _SectionHeader(
                      icon: Icons.work_history,
                      title: "Years of Experience",
                    ),
                    DropdownButtonFormField<int>(
                      value: selectedExperience,
                      decoration: const InputDecoration(
                        hintText: "Select experience",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      items: List.generate(10, (i) => i + 1)
                          .map((years) => DropdownMenuItem(
                                value: years,
                                child: Text(
                                    "$years ${years > 1 ? 'years' : 'year'}"),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedExperience = value),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (missingFields.contains('Fee')) ...[
                    const _SectionHeader(
                      icon: Icons.attach_money,
                      title: "Service Fee",
                    ),
                    TextFormField(
                      controller: feeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: "Rs. ",
                        hintText: "Enter fee per visit",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (missingFields.contains('Availability')) ...[
                    const _SectionHeader(
                      icon: Icons.access_time,
                      title: "Working Hours",
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _TimePickerButton(
                            label: "Start Time",
                            time: startTime,
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Colors
                                            .orangeAccent, // clock dial and OK button
                                        onSurface: Colors
                                            .orangeAccent, // numbers and text color
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setState(() => startTime = time);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TimePickerButton(
                            label: "End Time",
                            time: endTime,
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Colors
                                            .orangeAccent, // clock dial and OK button
                                        onSurface: Colors
                                            .orangeAccent, // numbers and text color
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) setState(() => endTime = time);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children:
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                              .map((day) => FilterChip(
                                    label: Text(day),
                                    selected: selectedDays.contains(day),
                                    onSelected: (selected) => setState(() {
                                      if (selected) {
                                        selectedDays.add(day);
                                      } else {
                                        selectedDays.remove(day);
                                      }
                                    }),
                                  ))
                              .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      final updates = <String, String>{};
                      if (missingFields.contains('Experience') &&
                          selectedExperience != null) {
                        updates['experience'] = '$selectedExperience years';
                      }
                      if (missingFields.contains('Fee') &&
                          feeController.text.isNotEmpty) {
                        updates['fee'] = 'Rs. ${feeController.text}';
                      }
                      if (missingFields.contains('Availability')) {
                        if (startTime != null && endTime != null) {
                          updates['availability'] =
                              '${startTime!.format(context)} - ${endTime!.format(context)}';
                        }
                        if (selectedDays.isNotEmpty) {
                          updates['working_days'] = selectedDays.join(', ');
                        }
                      }
                      if (updates.isNotEmpty && uid != null) {
                        await FirebaseFirestore.instance
                            .collection('workerProfiles')
                            .doc(uid)
                            .update(updates);
                        setState(() => workerData.addAll(updates));
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      await _loadProfileData();
                    },
                    child: const Text('Save Profile Details'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper Widgets

  // ---------------------------
  // Firebase & Form Logic
  // ---------------------------
  // final uid = FirebaseAuth.instance.currentUser?.uid;

  void _toggleProfileType() async {
    try {
      if (uid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not authenticated.')));
        }
        return;
      }

      if (isEmployer) {
        // Switching to Worker Profile
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('workerProfiles')
            .doc(uid)
            .get();
        if (doc.exists) {
          setState(() {
            workerData = (doc.data() as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, v?.toString() ?? ''));
            isEmployer = false;
          });
          _updateControllers();
        } else {
          _showWorkerProfileForm();
        }
      } else {
        // Switching to Employer Profile: Fetch latest data
        DocumentSnapshot employerDoc = await FirebaseFirestore.instance
            .collection('employerProfiles')
            .doc(uid)
            .get();
        if (employerDoc.exists) {
          setState(() {
            employerData = (employerDoc.data() as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, v?.toString() ?? ''));
            isEmployer = true;
          });
          _updateControllers();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Employer profile not found.')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated.')));
        setState(() => _isSaving = false);
        return;
      }

      // Pick the image
      File? imageToSave = pickedImage ?? _imageFile;
      // if (imageToSave == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Please select a profile image.')));
      //   setState(() => _isSaving = false);
      //   return;
      // }

      // Upload image first
      if (imageToSave != null) {
        await _putImageToSupabaseStorage(imageToSave);
      }
      // publicUrl will be available here

      // Save correct path
      if (publicUrl != null && publicUrl!.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path_$uid', publicUrl!);
      }
      debugPrint('😒publicUrl: $publicUrl');

      if (!_formKey.currentState!.validate()) {
        setState(() => _isSaving = false);
        return;
      }

      Map<String, String> updatedData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'role': _roleController.text.trim(),
        'about': _aboutController.text.trim(),
        'type': activeProfileData['type']!,
        'profileImageUrl': publicUrl ?? '',
      };

      String collection = isEmployer ? 'employerProfiles' : 'workerProfiles';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(uid)
          .update(updatedData);

      // Local cache update
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_email_$uid', updatedData['email'] ?? '');
      await prefs.setString('profile_phone_$uid', updatedData['phone'] ?? '');
      await prefs.setString(
          'profile_location_$uid', updatedData['location'] ?? '');
      await prefs.setString('profile_about_$uid', updatedData['about'] ?? '');

      setState(() {
        if (isEmployer) {
          employerData = updatedData;
        } else {
          workerData = updatedData;
        }
        _isEditing = false;
        // Clear local image state after save
        pickedImage = null;
        _imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showWorkerProfileForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: WorkerProfileForm(
          onSubmit: (profileData) async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            await FirebaseFirestore.instance
                .collection('workerProfiles')
                .doc(uid)
                .set(profileData);
            setState(() {
              workerData = profileData;
              isEmployer = false;
            });
            if (context.mounted) {
              Navigator.pop(context);
            }
            _updateControllers();
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onPressed;
  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 18),
          const SizedBox(width: 8),
          Text(
            time != null ? time!.format(context) : label,
            style: TextStyle(
                color: time != null
                    ? Colors.orangeAccent
                    : Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}
