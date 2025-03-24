import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  bool _isAppActive = true;
  final _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  void setAppActive(bool isActive) {
    _isAppActive = isActive;
    if (isActive) {
      _updateMessageStatus();
    }
  }

  void _updateMessageStatus() {
    if (!_isAppActive || _currentUserId == null) return;

    FirebaseFirestore.instance
        .collection('chatss')
        .where('receiverId', isEqualTo: _currentUserId)
        .where('status', isEqualTo: 'sent')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'status': 'delivered'});
      }
    });
  }
}
