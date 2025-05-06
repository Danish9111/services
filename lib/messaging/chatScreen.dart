import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'chat_database.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'customeLoader.dart';

class ChatScreen extends ConsumerStatefulWidget {
  // Receiver id passed from the previous screen
  final String receiverId;

  const ChatScreen({super.key, required this.receiverId});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final user = FirebaseAuth.instance.currentUser;
  late final String _currentUserId = user?.uid ?? 'yourUserId';
  final databaseRef = FirebaseDatabase.instance.ref();
  bool _isSending = false;
  bool _isViewingChat = false;
  bool _isReceiverOnline = false;
  bool _isOnline = false;
  String? _photoUrl;

  String _name = '';
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String getChatId(String a, String b) {
    return a.compareTo(b) < 0 ? '$a-$b' : '$b-$a';
  }

  @override
  void initState() {
    if (user != null) {
      databaseRef.child('users/$_currentUserId/online').set(true);
      databaseRef
          .child('users/$_currentUserId/online')
          .onDisconnect()
          .set(false);
      databaseRef
          .child('users/$_currentUserId/lastSeen')
          .onDisconnect()
          .set(ServerValue.timestamp);
    }
    super.initState();
    ref.read(lastSeenProvider.notifier).listenForLastSeen(widget.receiverId);
    listenForReceiverPresence();

    if (user != null) {
      setState(() {
        _photoUrl = user?.photoURL;
      });
    }

    WidgetsBinding.instance.addObserver(this);
    _fetchName();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Handle individual connectivity result
      setState(() {
        _isOnline = result == ConnectivityResult.none;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (user != null) {
      if (state == AppLifecycleState.resumed) {
        databaseRef.child('users/$_currentUserId/online').set(true);
        _isViewingChat = true;
      } else {
        _isViewingChat = false;
        databaseRef.child('users/$_currentUserId/online').set(false);
        databaseRef
            .child('users/$_currentUserId/lastSeen')
            .set(ServerValue.timestamp);
        ref.read(lastSeenProvider.notifier).updateLastSeen();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Fetches the name from workerProfiles collection using receiverId
  void _fetchName() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('workerProfiles')
        .doc(widget.receiverId)
        .get();
    if (docSnapshot.exists) {
      setState(() {
        _name = docSnapshot.get('name');
      });
    } else {
      setState(() {
        _name = 'no such user';
      });
    }
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    setState(() => _isSending = true);
    final messageText = _controller.text.trim();
    final chatId = getChatId(_currentUserId, widget.receiverId);
    final senderImageUrl = ref.read(profileImageProvider);

    try {
      // Prepare message data without isRead
      final messageData = {
        'senderId': _currentUserId,
        'receiverId': widget.receiverId,
        'chatId': chatId,
        'status': 'sent',
        'text': messageText,
        'timestamp': Timestamp.now(),
        'senderImageUrl': senderImageUrl,
      };

      // Add to Firestore
      await FirebaseFirestore.instance.collection('chatss').add(messageData);

      // Add to SQLite without isRead
      await ChatDatabase.instance.insertMessage({
        'senderId': _currentUserId,
        'receiverId': widget.receiverId,
        'chatId': chatId,
        'status': 'sent',
        'text': messageText,
        'timestamp': DateTime.now().toString(),
      });

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void listenForReceiverPresence() {
    FirebaseDatabase.instance
        .ref('users/${widget.receiverId}/online')
        .onValue
        .listen((event) {
      setState(() {
        _isReceiverOnline = event.snapshot.value == true;
      });
    });
  }

  void updateMessageStatus(List<QueryDocumentSnapshot> messages) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    for (var messageDoc in messages) {
      String status = messageDoc['status'] ?? 'sent';
      // Only update to 'read' if message was 'received'
      if (messageDoc['receiverId'] == currentUserId && status != 'read') {
        FirebaseFirestore.instance
            .collection('chatss')
            .doc(messageDoc.id)
            .update({'status': 'read'});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastSeen = ref.watch(lastSeenProvider);
    final lightDarkPro = ref.watch(lightDarkColorProvider);
    final darkColorPro = ref.watch(darkColorProvider);
    final lightColorPro = ref.watch(lightColorProvider);
    final isDark = ref.watch(isDarkProvider);
    const darkColor = Color.fromARGB(255, 63, 72, 76);

    // final senderImageUrl = ref.watch(profileImageProvider);

    final chatId = getChatId(_currentUserId, widget.receiverId);
    // Conditionally set the stream based on the viewing flag.
    final Stream<QuerySnapshot>? chatStream = _isViewingChat
        ? FirebaseFirestore.instance
            .collection('chatss')
            .where('chatId', isEqualTo: chatId)
            // .where('status', isNotEqualTo: 'read')
            .orderBy('timestamp', descending: false)
            .snapshots()
        : null;

    return VisibilityDetector(
        key: const Key('chat-screen-key'),
        onVisibilityChanged: (visibilityInfo) {
          final visiblePercentage = visibilityInfo.visibleFraction * 100;
          setState(() {
            _isViewingChat = visiblePercentage > 50;
          });
        },
        child: Scaffold(
          backgroundColor: lightDarkPro,
          appBar: AppBar(
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              // surfaceTintColor: darkColorPro,
              backgroundColor: darkColor,
              toolbarHeight: 80,
              elevation: 4,
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('employerProfiles')
                              .doc(widget.receiverId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              );
                            }
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data!.exists) {
                              debugPrint('you have data atleast 👌');
                              final data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final imageUrl =
                                  data['profileImageUrl'] as String?;
                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                debugPrint('you are right there ✅');
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    imageUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.person,
                                                size: 40, color: Colors.white),
                                  ),
                                );
                              }
                            }
                            return const Icon(
                              Icons.account_circle,
                              size: 40,
                              color: Colors.white,
                            );
                          },
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            _name.isEmpty ? 'Loading...' : _name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        _isReceiverOnline
                            ? 'Online'
                            : lastSeen != null
                                ? '${formatLastSeen(lastSeen)}'
                                : 'Loading...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              )),
          body: GestureDetector(
            // Dismiss the keyboard when tapping outside the input area
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                Expanded(
                  child: chatStream == null
                      ? PoorInternetConnection()
                      : StreamBuilder<QuerySnapshot>(
                          stream: chatStream,
                          builder: (context, snapshot) {
                            // Error handling
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                    'Error loading messages: ${snapshot.error}'),
                              );
                            }

                            // Show the loader only if there's no data at all
                            if (!snapshot.hasData || snapshot.data == null) {
                              return const Center(child: CustomLoader());
                            }

                            // Now that data exists, even if connection state is waiting,
                            // we don't show the loader
                            final messages = snapshot.data!.docs;

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_isViewingChat) {
                                final unreadMessages = messages
                                    .where((message) =>
                                        message['status'] != 'read')
                                    .toList();
                                if (unreadMessages.isNotEmpty) {
                                  try {
                                    updateMessageStatus(unreadMessages);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error updating status: $e')),
                                    );
                                  }
                                }
                              }
                            });

                            return ListView.separated(
                              reverse: true,
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: messages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 2),
                              itemBuilder: (context, index) {
                                final message =
                                    messages[messages.length - 1 - index];
                                final isMe =
                                    message['senderId'] == _currentUserId;

                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: _ChatBubble(
                                    text: message['text'],
                                    isMe: isMe,
                                    timestamp: message['timestamp']?.toDate(),
                                    status: isMe ? message['status'] : '',
                                    isOnline: _isOnline,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                _MessageInput(
                  controller: _controller,
                  onSend: _sendMessage,
                  isSending: _isSending,
                  isOnline: _isOnline,
                ),
              ],
            ),
          ),
        ));
  }
}

Widget PoorInternetConnection() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.wifi_off, size: 50, color: Colors.grey),
        SizedBox(height: 10),
        Text('Poor Internet Connection',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    ),
  );
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? timestamp;
  final String? status;
  final bool isOnline;

  const _ChatBubble({
    required this.text,
    required this.isMe,
    this.timestamp,
    this.status,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isMe ? Colors.blueAccent.shade200 : Colors.grey.shade300,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft:
              isMe ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight:
              isMe ? const Radius.circular(4) : const Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (timestamp != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('hh:mm a').format(timestamp!),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(width: 5),
              if (isMe && status != null) _buildStatusIcon(status!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    // Return the appropriate icon based on the status
    switch (status) {
      case 'sent':
        return const Icon(
          Icons.check,
          size: 16,
          color: Colors.white,
        );
      case 'received':
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.white,
        );
      case 'read':
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.amber,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _MessageInput extends ConsumerWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;
  final bool isOnline;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.isSending,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightColor = ref.watch(lightColorProvider);
    final darkColor = ref.watch(darkColorProvider);
    final isdark = ref.watch(isDarkProvider);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: !isdark ? darkColor : lightColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: !isdark ? lightColor : darkColor,
              width: 1,
            )),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send,
                  color: isSending ? Colors.grey : Colors.blueAccent),
              onPressed: isOnline
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No internet connection')),
                      );
                    }
                  : isSending
                      ? null
                      : onSend,
            ),
            if (isSending)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String formatLastSeen(AsyncValue<DateTime> asyncLastSeen) {
  return asyncLastSeen.when(
    data: (lastSeen) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final lastSeenDate =
          DateTime(lastSeen.year, lastSeen.month, lastSeen.day);

      if (lastSeenDate == today) {
        return 'Today at ${DateFormat.jm().format(lastSeen)}';
      } else if (lastSeenDate == yesterday) {
        return 'Yesterday at ${DateFormat.jm().format(lastSeen)}';
      } else {
        return '${DateFormat.yMd().format(lastSeen)} ${DateFormat.jm().format(lastSeen)}';
      }
    },
    loading: () => 'Last seen : Loading...',
    error: (error, stack) => 'Error fetching last seen',
  );
}
