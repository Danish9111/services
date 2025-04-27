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

File? _imageFile;

class EmployerProfile extends ConsumerStatefulWidget {
  const EmployerProfile({super.key});

  @override
  ConsumerState<EmployerProfile> createState() => _EmployerProfileState();
}

class _EmployerProfileState extends ConsumerState<EmployerProfile> {
  bool isEmployer = true;
  bool _isEditing = false;
  User? user = FirebaseAuth.instance.currentUser;

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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
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
      DocumentSnapshot workerDoc = await FirebaseFirestore.instance
          .collection('workerProfiles')
          .doc(uid)
          .get();

      if (workerDoc.exists) {
        setState(() {
          workerData = Map<String, String>.from(
              workerDoc.data() as Map<String, dynamic>);
        });
      }

      // Update controllers with fetched data.
      _updateControllers();
    } catch (e) {
      print("Error loading profile: $e");
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _imageFile = File(imagePath);
      });
      // Always update provider so drawer/dashboard get the image
      ref.read(profileImageProvider.notifier).state = imagePath;
    }
    // Do NOT reset provider to '' here unless user removed image
  }

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
      body: Container(
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
                ],
              ),
            ),
          ),
        ),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', picked.path);
    // Always update provider so drawer/dashboard get the image
    ref.read(profileImageProvider.notifier).state = picked.path;
    return File(picked.path);
  }

  void _removeProfileImage() async {
    setState(() {
      _imageFile = null;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
    // Only clear provider if user actually removes image
    ref.read(profileImageProvider.notifier).state = '';
  }

  Future<void> _putImageToSupabaseStorage(File imageFile) async {
    final supabase = sb.Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;
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
      final publicUrl = supabase.storage
          .from('profileimages')
          .getPublicUrl('uploads/$uid.jpg');

      try {
// 🔥 Save public URL locally for reuse
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_url', publicUrl);

// 🧠 Update provider too if needed
        ref.read(profileImageProvider.notifier).state = publicUrl;
      } catch (e) {
        debugPrint('❌ Error storing image info to sharedpreferences: $e');
      }

      // 3. update + select → returns List<Map<String, dynamic>>
      //    throws a PostgrestException on RLS or network errors
      final updatedRows = await supabase
          .from('employerProfiles')
          .update({'profileImage': publicUrl})
          .eq('firebase_uid', uid)
          .select(); // returns List<Map<String,dynamic>> :contentReference[oaicite:0]{index=0}

      if (updatedRows.isEmpty) {
        debugPrint('❌ No profile row was updated');
      } else {
        debugPrint('✅ Profile updated, sample return: ${updatedRows.first}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded to supabase')),
        );
      }
    } on sb.PostgrestException catch (e) {
      // catches RLS / HTTP / Postgrest errors
      debugPrint('❌ Supabase error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Supabase error: ${e.message}')),
      );
    } catch (e) {
      // catches any other errors (e.g. file IO)
      debugPrint('🔥 Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
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

  // ---------------------------
  // Firebase & Form Logic
  // ---------------------------
  void _toggleProfileType() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
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
    final original = pickedImage;
    // 1. Copy to app dir
    final appDir = await getApplicationDocumentsDirectory();
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}_${FirebaseAuth.instance.currentUser!.uid}.jpg';
    final savedFile = await original?.copy('${appDir.path}/$filename');

    // 2. Store that local path
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_profile_image', savedFile?.path ?? '');

    // 3. Upload to Supabase
    await _putImageToSupabaseStorage(savedFile!);
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated.')));
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
    };

    try {
      String collection = isEmployer ? 'employerProfiles' : 'workerProfiles';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(uid)
          .set(updatedData);

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
            Navigator.pop(context);
            _updateControllers();
          },
        ),
      ),
    );
  }
}
