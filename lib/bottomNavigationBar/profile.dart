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
          employerData = Map<String, String>.from(
              employerDoc.data() as Map<String, dynamic>);
        });
      }

      // Similarly, load worker profile data if needed.
      DocumentSnapshot workerDocs = await FirebaseFirestore.instance
          .collection('workerProfiles')
          .doc(uid)
          .get();

      if (workerDocs.exists) {
        setState(() {
          workerData = Map<String, String>.from(
              workerDocs.data() as Map<String, dynamic>);
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

    _loadProfileData();
    _loadLocalProfileImage(); // Load image from SharedPreferences if available
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
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
  }

  Future<void> _loadLocalProfileImage() async {
    if (uid == null) {
      setState(() {
        _imageFile = null;
      });
      ref.read(profileImageProvider.notifier).state = '';
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image_path_$uid');
    setState(() {
      _imageFile =
          (imagePath != null && imagePath.isNotEmpty) ? File(imagePath) : null;
    });
    ref.read(profileImageProvider.notifier).state = imagePath ?? '';
  }

  // Call this after login/logout/account switch to always load the correct image
  // Future<void> reloadProfileImageForCurrentUser() async {
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
                      _buildProfileCompletionSection(),
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
            child: ClipOval(
              child: (_imageFile != null)
                  ? Stack(
                      children: [
                        Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            color: lightColorPro,
                            size: 50,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () async {
                                _removeProfileImage();
                              },
                            ),
                          ),
                      ],
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.person,
                        color: lightColorPro,
                        size: 50,
                      ),
                      onPressed: () async {
                        if (_isEditing) {
                          File? pickedImage = await _pickPhoto();
                          if (pickedImage != null) {
                            setState(() {
                              _imageFile = pickedImage;
                            });
                          }
                        }
                      },
                    ),
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
                      borderSide: BorderSide(color: lightColorPro)),
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
                activeProfileData['name']!.isNotEmpty
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
            ? TextFormField(
                controller: _roleController,
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: lightColorPro),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: lightColorPro)),
                ),
                style: TextStyle(
                  fontSize: 18,
                  color: lightColorPro,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Text(
                activeProfileData['role']!.isNotEmpty
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
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    pickedImage = File(picked.path);
    // Save to SharedPreferences for persistence
    if (uid != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path_$uid', picked.path);
      // Always update provider so drawer/dashboard get the image
      ref.read(profileImageProvider.notifier).state = picked.path;
    }
    return File(picked.path);
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

      try {
        // 🔥 Save public URL locally for reuse
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('profile_image_url', publicUrl);

        // 🧠 Update provider too if needed
        ref.read(profileImageProvider.notifier).state = publicUrl;
      } catch (e) {
        debugPrint('❌ Error storing image info to sharedpreferences: $e');
      }

      // 3. update + select → returns List<Map<String, dynamic>>
      //    throws a PostgrestException on RLS or network errors
      // final updatedRows = await supabase
      //     .from('employerProfiles')
      //     .update({'profileImage': publicUrl})
      //     .eq('firebase_uid', uid)
      //     .select();

      // 4. Update Firestore senderImageUrl for chat display
      try {
        await FirebaseFirestore.instance
            .collection('employerProfiles')
            .doc(uid)
            .update({'senderImageUrl': publicUrl});
      } catch (e) {
        debugPrint('❌ Error uploading profile image url to  Firestore: $e');
      }

      // if (updatedRows.isEmpty) {
      //   debugPrint('❌ No profile row was updated');
      // } else {
      //   debugPrint('✅ Profile updated, sample return: \\${updatedRows.first}');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Image uploaded to supabase')),
      //   );
      // }
    } on sb.PostgrestException catch (e) {
      // catches RLS / HTTP / Postgrest errors
      debugPrint('❌ Supabase error: \\${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Supabase error: \\${e.message}')),
      );
    } catch (e) {
      // catches any other errors (e.g. file IO)
      debugPrint('🔥 Unexpected error: \\${e}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: \\${e}')),
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

  Widget _buildProfileCompletionSection() {
    // 3 additional fields for completion:
    final additionalFields = <String, String>{
      'Experience': workerData['experience'] ?? '',
      'Fee': workerData['fee'] ?? '',
      'Availability': workerData['availability'] ?? '',
    };
    final missingAdditional = additionalFields.entries
        .where((entry) => entry.value.isEmpty)
        .map((entry) => entry.key)
        .toList();
    final completedCount = additionalFields.length - missingAdditional.length;
    final percent = ((completedCount / additionalFields.length) * 100).round();
    final isComplete = missingAdditional.isEmpty;

    if (isComplete) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orangeAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile completion: $percent%',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add the following to complete your professional profile: ${missingAdditional.join(', ')}',
                  style: TextStyle(color: Colors.orange.shade900, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _showCompleteProfileModal(missingAdditional);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Complete Profile'),
                ),
              ],
            ),
          ),
        ],
      ),
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
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
                      backgroundColor: theme.primaryColor,
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
                          updates['working_days'] = 'selectedDays';
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
            workerData =
                Map<String, String>.from(doc.data() as Map<String, dynamic>);
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
            employerData = Map<String, String>.from(
                employerDoc.data() as Map<String, dynamic>);
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
      final original = pickedImage;
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated.')));
        setState(() => _isSaving = false);
        return;
      }
      // 1. Copy to app dir if a new image was picked
      File? imageToSave = original ?? _imageFile;
      String? imagePath;
      if (imageToSave != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final filename = '$uid.jpg';
        final savedFile = await imageToSave.copy('${appDir.path}/$filename');
        imagePath = savedFile.path;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path_$uid', imagePath);
      }
      // Only require an image if there is none at all
      if (imageToSave == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a profile image before saving.')),
        );
        setState(() => _isSaving = false);
        return;
      }
      // 3. Upload to Supabase
      await _putImageToSupabaseStorage(imageToSave);
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
      try {
        String collection = isEmployer ? 'employerProfiles' : 'workerProfiles';
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(uid)
            .set(updatedData);
        // Update cache after save
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
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully.')));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Save failed: $e")));
        }
      }
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
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}
