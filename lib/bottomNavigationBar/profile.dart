import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'workerProfileForm.dart';
import 'package:firebase_storage/firebase_storage.dart';

// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
File? _imageFile; // Declare this at the top of your class

final Color _primaryColor = Colors.blue.shade800;
final Color _secondaryColor = Colors.orange.shade600;

class EmployerProfile extends StatefulWidget {
  const EmployerProfile({super.key});

  @override
  State<EmployerProfile> createState() => _EmployerProfileState();
}

class _EmployerProfileState extends State<EmployerProfile> {
  bool isEmployer = true;
  bool _isEditing = false;
  User? user = FirebaseAuth.instance.currentUser;

  // Employer data remains static initially.
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

  // Worker data will be updated once the user submits the form.
  Map<String, String> workerData = {
    'name': '',
    'email': '',
    'phone': '',
    'location': '',
    'jobTitle': '',
    'role': '',
    'about': '',
    'type': 'Worker'
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
      // Handle errors accordingly.
      print("Error loading profile: $e");
    }
  }

  // Get active profile data
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

    // Initialize controllers with current profile data.
    _nameController = TextEditingController(text: activeProfileData['name']);
    _emailController = TextEditingController(text: activeProfileData['email']);
    _phoneController = TextEditingController(text: activeProfileData['phone']);
    _locationController =
        TextEditingController(text: activeProfileData['location']);
    _roleController = TextEditingController(text: activeProfileData['role']);
    _aboutController = TextEditingController(text: activeProfileData['about']);
  }

  @override
  void dispose() {
    // Dispose controllers.
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
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
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
          )),
          backgroundColor: Colors.blueGrey.shade600,
        ),
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 10),
                    _buildRoleSwitchCard(),
                    const SizedBox(height: 10),
                    _buildInfoSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  // ---------------------------
  // UI Building Methods
  // ---------------------------

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _primaryColor, width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: (_imageFile != null)
                  ? Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: _primaryColor,
                        size: 50,
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.person,
                        color: _primaryColor,
                        size: 50,
                      ),
                      onPressed: () async {
                        if (_isEditing) {
                          File? pickedImage = await _pickPhotoFromPhone();
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
        // If editing, show a TextFormField; otherwise, show the text.
        _isEditing
            ? TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: _primaryColor),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _primaryColor)),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Name cannot be empty"
                    : null,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              )
            : Text(
                activeProfileData['name']!.isNotEmpty
                    ? activeProfileData['name']!
                    : "No Name",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
        const SizedBox(height: 5),
        _isEditing
            ? TextFormField(
                controller: _roleController,
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: _secondaryColor),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _secondaryColor)),
                ),
                style: TextStyle(
                  fontSize: 18,
                  color: _secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Text(
                activeProfileData['role']!.isNotEmpty
                    ? activeProfileData['role']!
                    : "No Role",
                style: TextStyle(
                  fontSize: 18,
                  color: _secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
      ],
    );
  }

  Future<File?> _pickPhotoFromPhone() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _putImageToFireBaseStorage(imageFile);
      return imageFile;
    } else {
      return null;
    }
  }

  Future<void> _putImageToFireBaseStorage(File imageFile) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final storageRef =
        FirebaseStorage.instance.ref().child('profileImages/$uid.jpg');
    storageRef.putFile(imageFile).then((taskSnapshot) {
      taskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        // Save the download URL to Firestore or use it as needed.
        FirebaseFirestore.instance
            .collection('employerProfiles')
            .doc(uid)
            .update({
          'profileImage': downloadUrl,
        });
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading image: $error")));
    });
  }

  Widget _buildRoleSwitchCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
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
                color: Colors.grey.shade700,
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
                      activeProfileData['type']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isEmployer ? _primaryColor : _secondaryColor,
                      ),
                    ),
                  ),
                  // const SizedBox(height: 4),
                  Transform.rotate(
                    angle: -0.1,
                    child: Opacity(
                      opacity: 0.8,
                      child: SizedBox(
                        // The SizedBox width will match the intrinsic width from the column
                        width: double.infinity,
                        child: Image.asset(
                          'assets/brush_stroke.png',
                          height: 8, // Adjust this height for a subtle effect
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

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildEditableEmailField(Icons.email, 'Email', _emailController,
            validatorMsg: "Email cannot be empty"),
        _buildEditableField(Icons.phone, 'Phone', _phoneController,
            validatorMsg: "Phone cannot be empty"),
        _buildEditableField(Icons.location_on, 'Location', _locationController,
            validatorMsg: "Location cannot be empty"),
        const SizedBox(height: 10),
        _buildAboutCard(),
      ],
    );
  }

  Widget _buildEditableEmailField(
      IconData icon, String label, TextEditingController controller,
      {String? validatorMsg}) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor),
      title: _isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: _primaryColor),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _primaryColor)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email cannot be empty";
                }
                // Simple email regex pattern.
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
              style: const TextStyle(fontSize: 16),
            ),
    );
  }

  Widget _buildEditableField(
      IconData icon, String label, TextEditingController controller,
      {String? validatorMsg}) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor),
      title: _isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: _primaryColor),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _primaryColor)),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? validatorMsg : null,
            )
          : Text(
              controller.text,
              style: const TextStyle(fontSize: 16),
            ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: _primaryColor),
                const SizedBox(width: 8),
                Text(
                  'About ${activeProfileData['type']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
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
                      labelStyle: TextStyle(color: _primaryColor),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _primaryColor)),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "About cannot be empty"
                        : null,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  )
                : Text(
                    activeProfileData['about']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // If in editing mode, show Save button; else, show Edit button.
        _isEditing
            ? ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Save Profile',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saveProfile,
              )
            : ElevatedButton.icon(
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text('Edit Profile',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Enter edit mode and update controllers with current data.
                  setState(() {
                    _isEditing = true;
                  });
                  _updateControllers();
                },
              ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: Icon(Icons.swap_horiz, color: _primaryColor),
          label: Text(
            'Switch to ${isEmployer ? 'Worker' : 'Employer'} Profile',
            style: TextStyle(color: _primaryColor),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
            side: BorderSide(color: _primaryColor),
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
      if (isEmployer) {
        // Switching from Employer to Worker Profile.
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not authenticated.')));
          return;
        }
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
        } else {
          // Show form or prompt to create worker profile.
          _showWorkerProfileForm();
        }
      } else {
        setState(() {
          isEmployer = true;
        });
      }
      // Update controllers after switching.
      _updateControllers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _saveProfile() async {
    // Validate form fields before saving.
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated.')));
      return;
    }

    // Prepare updated profile data.
    Map<String, String> updatedData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'location': _locationController.text.trim(),
      'role': _roleController.text.trim(),
      'about': _aboutController.text.trim(),
      'type': activeProfileData['type']!, // Remains the same.
    };

    try {
      // Save to the proper Firestore collection.
      String collection = isEmployer ? 'employerProfiles' : 'workerProfiles';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(uid)
          .set(updatedData);

      setState(() {
        // Update local data.
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

  /// Shows the bottom sheet containing the worker profile form.
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
            // Update controllers after creating worker profile.
            _updateControllers();
          },
        ),
      ),
    );
  }
}
