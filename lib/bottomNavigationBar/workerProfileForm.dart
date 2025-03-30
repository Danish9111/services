import 'package:flutter/material.dart';

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
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your location' : null,
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
                validator: (value) =>
                    value == null ? 'Please select a profession' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _aboutController,
                decoration: const InputDecoration(labelText: 'About'),
                maxLines: 3,
                validator: (value) => value!.isEmpty
                    ? 'Please tell something about yourself'
                    : null,
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
