// // messages_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'chat_database.dart';

// final messagesProvider =
//     StateNotifierProvider<MessagesNotifier, AsyncValue<List<Message>>>(
//   (ref) => MessagesNotifier(),
// );

// class MessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
//   MessagesNotifier() : super(const AsyncValue.loading()) {
//     _loadMessagesFromCache();
//   }

//   // Load messages from the local SQLite database
//   Future<void> _loadMessagesFromCache() async {
//     try {
//       final cachedMessages = await ChatDatabase.instance.getMessages();
//       state = AsyncValue.data(cachedMessages);
//     } catch (e, st) {
//       state = AsyncValue.error(e, st);
//     }
//   }

//   // Listen for new messages from Firebase and update state + local cache
//   Future<void> listenForMessages(String chatRoomId) async {
//     FirebaseDatabase.instance
//         .ref('chatRooms/$chatRoomId/messages')
//         .onValue
//         .listen((event) async {
//       // Parse Firebase snapshot into a list of Message objects
//       final messages = parseMessages(event.snapshot);
//       // Update provider state
//       state = AsyncValue.data(messages);
//       // Update local cache
//       await ChatDatabase.instance.saveMessages(messages);
//     });
//   }

//   // Parse Firebase snapshot data into a list of Message objects
//   List<Message> parseMessages(DataSnapshot snapshot) {
//     final data = snapshot.value as Map<dynamic, dynamic>?;
//     if (data == null) return [];
//     List<Message> messages = [];
//     data.forEach((key, value) {
//       // Ensure the value is a Map<String, dynamic>
//       final messageMap = Map<String, dynamic>.from(value);
//       messages.add(Message.fromMap(messageMap));
//     });
//     // Sort messages by timestamp if needed
//     messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
//     return messages;
//   }
// }
