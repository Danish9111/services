import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:services/providers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactUsPage extends ConsumerStatefulWidget {
  const ContactUsPage({super.key});

  @override
  ConsumerState<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends ConsumerState<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  static const _phoneNumber = '+923144881902';
  static const _email = 'nadeemdanish.9188.1@gmail.com';
  static const _accentColor = Colors.orangeAccent;

  @override
  Widget build(BuildContext context) {
    final bgColor = ref.watch(lightDarkColorProvider);
    final appBarColor = ref.watch(darkColorProvider);
    final textColor =
        ref.watch(lightColorProvider); // light on dark, dark on light

    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us', style: TextStyle(color: textColor)),
        centerTitle: true,
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: _accentColor),
        actionsIconTheme: const IconThemeData(color: _accentColor),
      ),
      body: Container(
        color: bgColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(textColor),
              const SizedBox(height: 30),
              _buildContactMethods(textColor, appBarColor),
              const SizedBox(height: 30),
              _buildContactForm(textColor),
              const SizedBox(height: 20),
              _buildSocialMedia(textColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Column(
      children: [
        const Icon(Icons.support_agent, size: 50, color: _accentColor),
        const SizedBox(height: 15),
        const Text(
          'We\'re here to help!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _accentColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Get in touch with us through any of the following methods',
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildContactMethods(Color textColor, Color cardColor) {
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: _accentColor),
              title: const Text('Call Us',
                  style: TextStyle(
                      color: _accentColor, fontWeight: FontWeight.w600)),
              subtitle: Text(_phoneNumber, style: TextStyle(color: textColor)),
              onTap: () => _launchPhone(_phoneNumber),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.email, color: _accentColor),
              title: const Text('Email Us',
                  style: TextStyle(
                      color: _accentColor, fontWeight: FontWeight.w600)),
              subtitle: Text(_email, style: TextStyle(color: textColor)),
              onTap: () => _launchEmail(_email),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm(Color textColor) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Or send us a message directly',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Your Name',
              labelStyle: TextStyle(color: textColor),
              prefixIcon: const Icon(Icons.person, color: _accentColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: textColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: _accentColor),
              ),
            ),
            validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Your Email',
              labelStyle: TextStyle(color: textColor),
              prefixIcon: const Icon(Icons.email, color: _accentColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: textColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: _accentColor),
              ),
            ),
            validator: (v) =>
                !v!.contains('@') ? 'Please enter a valid email' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _messageController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Message',
              labelStyle: TextStyle(color: textColor),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: textColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: _accentColor),
              ),
            ),
            maxLines: 5,
            validator: (v) => v!.length < 10
                ? 'Message should be at least 10 characters'
                : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Send Message',
                style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMedia(Color textColor) {
    return Column(
      children: [
        Text('Find us on social media',
            style: TextStyle(color: textColor, fontSize: 14)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
                icon: Icons.facebook,
                color: Colors.blue,
                url: 'https://www.facebook.com/nadeem.danish.7967/'),
            const SizedBox(width: 20),
            _buildSocialIcon(
                icon: FontAwesomeIcons.linkedin,
                color: Colors.blueGrey,
                url: 'https://www.linkedin.com/in/sana-ullah-4b26561ba/'),
            const SizedBox(width: 20),
            _buildSocialIcon(
                icon: FontAwesomeIcons.github,
                color: Colors.black,
                url: 'https://github.com/Danish9111'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(
      {required IconData icon, required Color color, required String url}) {
    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: () async {
        try {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open link: $e')),
            );
          }
        }
      },
      style: IconButton.styleFrom(
        backgroundColor: _accentColor.withOpacity(0.1),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _launchPhone(String phone) async {
    final url = Uri(scheme: 'tel', path: phone);
    try {
      final canLaunch = await canLaunchUrl(url);
      debugPrint('canLaunchUrl for phone: $canLaunch');
      if (canLaunch) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Could not launch phone app. canLaunchUrl: $canLaunch')));
      }
    } catch (e, stack) {
      debugPrint('Error launching phone: $e');
      debugPrint('Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error launching phone app: $e')));
      }
    }
  }

  void _launchEmail(String email) async {
    final url = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': 'App Support'});
    try {
      final canLaunch = await canLaunchUrl(url);
      debugPrint('canLaunchUrl for email: $canLaunch');
      if (canLaunch) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch email client')));
      }
    } catch (e, stack) {
      debugPrint('Error launching email: $e');
      debugPrint('Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final mailOptions = MailOptions(
        body: _messageController.text,
        subject: 'Contact Form Submission',
        recipients: [_email],
        isHTML: false,
      );
      try {
        await FlutterMailer.send(mailOptions);
        _showSuccessDialog();
        _clearForm();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error sending message: $e')));
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Message Sent'),
        content:
            const Text('We’ve received your message and will respond shortly.'),
        actions: [
          TextButton(
            // use the dialog’s own context to pop its route
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
