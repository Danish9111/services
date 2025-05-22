import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

//used in drawer
final userEmailProvider = StateProvider<String?>((ref) => "");
final userNameProvider = StateProvider<String?>((ref) => null);
final userProfileProvider = StateProvider<String?>((ref) => null);

final darkColorProvider = Provider<Color>((ref) {
  final isDark = ref.watch(isDarkProvider);
  return isDark ? const Color.fromARGB(255, 63, 72, 76) : Colors.white;
});
final lightDarkColorProvider = Provider<Color>(
  (ref) {
    final isDark = ref.watch(isDarkProvider);
    return isDark ? const Color.fromARGB(255, 82, 89, 92) : Colors.white;
  },
);

final lightColorProvider = Provider<Color>((ref) {
  final isDark = ref.watch(isDarkProvider);
  return isDark ? Colors.white : const Color.fromARGB(255, 63, 72, 76);
});

final isDarkProvider = StateProvider<bool>((ref) => false);

final lastSeenProvider =
    StateNotifierProvider<LastSeenNotifier, AsyncValue<DateTime>>(
  (ref) => LastSeenNotifier(),
);

class LastSeenNotifier extends StateNotifier<AsyncValue<DateTime>> {
  LastSeenNotifier() : super(const AsyncValue.loading());

  void listenForLastSeen(String receiverId) {
    final ref = FirebaseDatabase.instance.ref('users/$receiverId/lastSeen');
    ref.onValue.listen((event) {
      final timestamp = event.snapshot.value;
      if (timestamp is int) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        state = AsyncValue.data(date);
      }
    }, onError: (error) {
      state = AsyncValue.error(error, StackTrace.current);
    });
  }

  Future<void> updateLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt('lastSeen', now.millisecondsSinceEpoch);
    state = AsyncValue.data(now);
  }
}

final profileImageProvider = StateProvider<String?>((ref) => null);

final notificationCountProvider = StateProvider<int>((ref) => 0);
