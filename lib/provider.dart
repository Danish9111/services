// provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

final lastSeenProvider =
    StateNotifierProvider<LastSeenNotifier, AsyncValue<DateTime>>(
  (ref) => LastSeenNotifier(),
);

class LastSeenNotifier extends StateNotifier<AsyncValue<DateTime>> {
  LastSeenNotifier() : super(const AsyncValue.loading()) {
    // Attempt to load cached value immediately on initialization
    _loadLastSeenFromCache();
  }

  // Load last seen value from SharedPreferences
  Future<void> _loadLastSeenFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('lastSeen');
    if (timestamp != null) {
      state = AsyncValue.data(DateTime.fromMillisecondsSinceEpoch(timestamp));
    }
  }

  // Listen for Firebase updates and update both state and cache
  Future<void> listenForLastSeen(String receiverId) async {
    FirebaseDatabase.instance
        .ref('users/$receiverId/lastSeen')
        .onValue
        .listen((event) async {
      final timestamp = event.snapshot.value;
      if (timestamp != null) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
        state = AsyncValue.data(dateTime);

        // Update the cache with the new value
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastSeen', dateTime.millisecondsSinceEpoch);
      } else {
        state = AsyncValue.error('Invalid timestamp', StackTrace.current);
      }
    });
  }
}

// final receiverPresenceProvider = StreamProvider.autoDispose<bool>((ref) {
//   return FirebaseDatabase.instance
//       .ref('users${receiverId}online')
//       .onValue
//       .map((event) => event.snapshot.value == true);
// });
