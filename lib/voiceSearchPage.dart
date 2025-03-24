import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchBottomSheet extends StatefulWidget {
  const VoiceSearchBottomSheet({super.key});

  @override
  VoiceSearchBottomSheetState createState() => VoiceSearchBottomSheetState();
}

class VoiceSearchBottomSheetState extends State<VoiceSearchBottomSheet> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _searchQuery = '';
  String _errorMessage = '';
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _checkMicrophonePermission();
  }

  Future<void> _checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      setState(() {
        _permissionGranted = status == PermissionStatus.granted;
        _errorMessage =
            _permissionGranted ? '' : 'Microphone permission is required for voice search';
      });
    } catch (e) {
      setState(() => _errorMessage = 'Error checking microphone permissions: $e');
    }
  }

  Future<void> _startListening() async {
    // Re-check permission before starting
    if (!_permissionGranted) {
      await _checkMicrophonePermission();
      if (!_permissionGranted) return;
    }

    try {
      final available = await _speech.initialize(
        onStatus: _handleStatusChange,
        onError: (error) => _handleError(error.errorMsg),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _searchQuery = ''; // Clear previous query when starting
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _searchQuery = result.recognizedWords;
            });
          },
        );
      }
    } catch (e) {
      _handleError('Error initializing speech recognition: $e');
    }
  }

  void _handleStatusChange(String status) {
    if (status == 'notListening' && _isListening) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _handleError(String error) {
    setState(() {
      _errorMessage = error;
      _isListening = false;
    });
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() => _isListening = false);
    } catch (e) {
      _handleError('Error stopping speech recognition: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Make the modal sheet take full width
      width: MediaQuery.of(context).size.width,
      // Limit the height to a fraction of the screen height
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: _errorMessage.isNotEmpty ? _buildErrorSection() : _buildMainContent(),
    );
  }

  Widget _buildErrorSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 16),
        Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () async {
            await _checkMicrophonePermission();
            if (_permissionGranted) {
              setState(() => _errorMessage = '');
            }
          },
          child: const Text('Grant Permission'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildVoiceInputDisplay(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Voice Search',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, _searchQuery),
        ),
      ],
    );
  }

  Widget _buildVoiceInputDisplay() {
    // A professionally styled, read-only display container for recognized text
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        _searchQuery.isEmpty ? 'Your voice input will appear here...' : _searchQuery,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(
              _isListening ? Icons.stop : Icons.mic,
              color: Colors.white,
            ),
            label: _isListening
                ? const AnimatedDots(baseText: 'Listening')
                : const Text(
                    'Start',
                    style: TextStyle(color: Colors.white),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => Navigator.pop(context, _searchQuery),
            label: const Text(
              'Search',
              selectionColor: Colors.blueGrey,
            ),
            icon: const Icon(Icons.search),
          ),
        ),
      ],
    );
  }
}

class AnimatedDots extends StatefulWidget {
  final String baseText;
  const AnimatedDots({super.key, required this.baseText});

  @override
  AnimatedDotsState createState() => AnimatedDotsState();
}

class AnimatedDotsState extends State<AnimatedDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {
          // Cycle through 0 to 3 dots.
          _dotCount = ((_controller.value * 4).floor() % 4);
        });
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.baseText,
          style: const TextStyle(color: Colors.white),
        ),
        SizedBox(
          width: 30, // Fixed width to keep the dots area constant
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '.' * _dotCount,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
