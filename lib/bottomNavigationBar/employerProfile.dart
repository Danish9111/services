import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../editableTextDemo.dart';

class EmployerProfile extends StatefulWidget {
  const EmployerProfile({super.key});

  @override
  State<EmployerProfile> createState() => _EmployerProfileState();
}

class _EmployerProfileState extends State<EmployerProfile> {
  bool isEmployer = true;
  final Color _primaryColor = Colors.blue.shade800;
  final Color _secondaryColor = Colors.orange.shade600;

  // A getter that returns the active profile data based on isEmployer.
  Map<String, String> get activeProfileData => isEmployer ? employerData : workerData;
  User? user = FirebaseAuth.instance.currentUser;

  // Employer data remains static.
  final Map<String, String> employerData = {
    'name': 'John Doe',
    'email': 'johndoe@example.com',
    'phone': '123-456-7890',
    'location': 'New York, USA',
    'jobTitle': 'Job Provider',
    'role': 'Painting, Mechanics, Plumbing',
    'about': 'Experienced job provider connecting skilled workers with quality opportunities.',
    'type': 'Employer'
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile Data"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 0),
              _buildRoleSwitchCard(),
              const SizedBox(height: 10),
              _buildInfoSection(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
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
              child: (user != null && user?.photoURL != null)
                  ? Image.network(
                      user!.photoURL!, // Correctly access the user photoURL here
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: _primaryColor,
                        size: 50,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: _primaryColor,
                      size: 50,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          activeProfileData['name']!.isNotEmpty ? activeProfileData['name']! : "No Name",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          activeProfileData['role']!.isNotEmpty ? activeProfileData['role']! : "No Role",
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

  Widget _buildRoleSwitchCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Profile Type:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            Chip(
              backgroundColor: isEmployer ? _primaryColor : _secondaryColor,
              label: Text(
                activeProfileData['type']!,
                style: const TextStyle(color: Colors.white),
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
        _buildInfoTile(Icons.email, 'Email', activeProfileData['email']!),
        _buildInfoTile(Icons.phone, 'Phone', activeProfileData['phone']!),
        _buildInfoTile(Icons.location_on, 'Location', activeProfileData['location']!),
        const SizedBox(height: 10),
        _buildAboutCard(),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor),
      title: Text(title, style: TextStyle(color: Colors.grey.shade600)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
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
            Text(
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
        ElevatedButton.icon(
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              // Navigate to EditableTextDemo screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditableTextDemo()),
              );
            }),
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
  // Firebase Check & Form Logic
  // ---------------------------
  /// Checks if a worker profile exists in Firestore.
  /// If it exists, simply switches the profile;
  /// if not, displays the form to collect the worker's details.
  void _toggleProfileType() async {
    try {
      if (isEmployer) {
        // Attempt to switch from Employer to Worker Profile.
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('error:')));
        }
        // Handle unauthenticated state as needed.
        DocumentSnapshot doc =
            await FirebaseFirestore.instance.collection('workerProfiles').doc(uid!).get();
        if (doc.exists) {
          // Worker profile exists: update local workerData and switch.
          setState(() {
            workerData = Map<String, String>.from(doc.data() as Map<String, dynamic>);
            isEmployer = false;
          });
        } else {
          // No worker profile exists: show form to collect details.
          _showWorkerProfileForm();
        }
      } else {
        // Switch back to Employer Profile.
        setState(() {
          isEmployer = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  /// Shows the bottom sheet containing the worker profile form.
  void _showWorkerProfileForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        // Adjust padding to account for the on-screen keyboard.
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: WorkerProfileForm(
          onSubmit: (profileData) async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            // Upload the worker profile to Fire store.
            await FirebaseFirestore.instance.collection('workerProfiles').doc(uid).set(profileData);
            setState(() {
              workerData = profileData;
              isEmployer = false;
            });

            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit_attributes, color: _primaryColor),
              title: const Text('Edit Personal Information'),
              onTap: () {
                // Implement edit personal info.
              },
            ),
            ListTile(
              leading: Icon(Icons.work_history, color: _primaryColor),
              title: Text('Update ${isEmployer ? 'Company' : 'Work'} Details'),
              onTap: () {
                // Implement edit work details.
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: _primaryColor),
              title: const Text('Change Password'),
              onTap: () {
                // Implement password change.
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------------
/// WorkerProfileForm:
/// This form collects the worker’s details including a dropdown
/// for the profession (category). Once submitted, the form data is
/// passed back via the onSubmit callback.
/// ------------------------------------------------------------------
class WorkerProfileForm extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;

  const WorkerProfileForm({super.key, required this.onSubmit});

  @override
  _WorkerProfileFormState createState() => _WorkerProfileFormState();
}

class _WorkerProfileFormState extends State<WorkerProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  String? _selectedProfession;
  final List<String> _professions = [
    'Painter',
    'Mechanic',
    'Plumber',
    'Electrician',
    'Carpenter',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedProfession != null) {
      // Build the profile data map.
      Map<String, String> profileData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'jobTitle': _selectedProfession!, // Use the selected profession.
        'role': _selectedProfession!,
        'about': _aboutController.text.trim(),
        'type': 'Worker',
      };

      widget.onSubmit(profileData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create Worker Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Please enter your location' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Profession'),
                items: _professions.map((profession) {
                  return DropdownMenuItem<String>(
                    value: profession,
                    child: Text(profession),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProfession = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a profession' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _aboutController,
                decoration: const InputDecoration(labelText: 'About'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please tell something about yourself' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
