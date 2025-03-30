import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

final colorProvider = Provider<Color>((ref) {
  final isDark = ref.watch(
      isDarkProvider); // Watch another provider that controls the theme state
  return isDark ? Colors.blueGrey.shade600 : Colors.white;
});
final isDarkProvider =
    StateProvider<bool>((ref) => false); // Initial value is false (light theme)

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
}
