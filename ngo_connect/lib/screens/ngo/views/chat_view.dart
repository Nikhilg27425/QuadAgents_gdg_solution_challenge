import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/firebase_service.dart';
import '../../../theme.dart';

/// ChatView — per-task group chat backed by Firestore Realtime.
///
/// Requirements 8.1–8.5:
///   8.1  Chat room auto-created when 2+ volunteers are assigned.
///   8.2  Messages stored in chat_rooms/{taskId}/messages with sender info.
///   8.3  Messages displayed in chronological order via live stream.
///   8.4  Auto-scroll to latest message on new arrival.
///   8.5  Access control: only participantIds members may read messages.
class ChatView extends StatefulWidget {
  /// The task/need id that identifies the chat room.
  final String taskId;

  /// Display name of the task (shown in the header).
  final String taskTitle;

  const ChatView({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// `null`  = still loading
  /// `true`  = access granted
  /// `false` = access denied (403)
  bool? _accessGranted;

  String get _currentUid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  String get _currentName =>
      FirebaseAuth.instance.currentUser?.displayName ?? '';

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Access control (Requirement 8.5) ──────────────────────────────────────

  /// Reads the chat_rooms document and verifies the current user is a participant.
  Future<void> _checkAccess() async {
    final uid = _currentUid;
    if (uid.isEmpty) {
      setState(() => _accessGranted = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.taskId)
        .get();

    if (!doc.exists) {
      // Room doesn't exist yet — allow access so the first message can create it.
      setState(() => _accessGranted = true);
      return;
    }

    final participants =
        List<String>.from(doc.data()?['participantIds'] ?? []);
    setState(() => _accessGranted = participants.contains(uid));
  }

  // ── Send message (Requirement 8.2) ────────────────────────────────────────

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _msgController.clear();

    // Fetch name from Firestore profile (more reliable than displayName)
    String senderName = _currentName;
    if (senderName.isEmpty) {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUid)
          .get();
      senderName = (profile.data() as Map<String, dynamic>?)?['name']
              as String? ??
          'User';
      // Also check ngos collection
      if (senderName == 'User') {
        final ngoProfile = await FirebaseFirestore.instance
            .collection('ngos')
            .doc(_currentUid)
            .get();
        senderName = (ngoProfile.data() as Map<String, dynamic>?)?['name']
                as String? ??
            'User';
      }
    }

    await FirebaseService.sendMessage(widget.taskId, {
      'senderUid': _currentUid,
      'senderName': senderName,
      'text': trimmed,
    });
  }

  // ── Auto-scroll (Requirement 8.4) ─────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_accessGranted == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_accessGranted == false) {
      return _buildAccessDenied();
    }

    return _buildChatUI();
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 64, color: AppTheme.textGrey),
          const SizedBox(height: 16),
          Text(
            'Access Denied',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppTheme.errorRed),
          ),
          const SizedBox(height: 8),
          const Text(
            'You are not a participant in this chat room.',
            style: TextStyle(color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildChatUI() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessageList()),
          _buildQuickReplies(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderGrey)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group, color: AppTheme.primaryPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.taskTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Group Chat',
                  style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Message list (Requirements 8.3 + 8.4) ─────────────────────────────────

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getMessagesStream(widget.taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        // Auto-scroll whenever new messages arrive.
        if (docs.isNotEmpty) {
          _scrollToBottom();
        }

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet. Start the conversation!',
              style: TextStyle(color: AppTheme.textGrey),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final isMine = data['senderUid'] == _currentUid;
            return _buildMessageBubble(data, isMine);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMine) {
    final text = data['text'] as String? ?? '';
    final rawSenderName = data['senderName'] as String? ?? 'Unknown';
    final senderUid = data['senderUid'] as String? ?? '';
    final sentAt = (data['sentAt'] as Timestamp?)?.toDate();
    final timeStr = sentAt != null
        ? '${sentAt.hour.toString().padLeft(2, '0')}:${sentAt.minute.toString().padLeft(2, '0')}'
        : '';

    // If senderName looks like an email, resolve the real name from Firestore
    final isEmail = rawSenderName.contains('@');

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: isEmail && senderUid.isNotEmpty
                    ? FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(senderUid)
                            .get(),
                        builder: (context, snap) {
                          final name =
                              (snap.data?.data() as Map<String, dynamic>?)?['name']
                                  as String? ??
                              rawSenderName;
                          return Text(name,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textGrey,
                                  fontWeight: FontWeight.w600));
                        },
                      )
                    : Text(rawSenderName,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textGrey,
                            fontWeight: FontWeight.w600)),
              ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMine
                    ? AppTheme.primaryPurple
                    : AppTheme.backgroundLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                        color: isMine ? Colors.white : AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: TextStyle(
                        fontSize: 10,
                        color: isMine ? Colors.white70 : AppTheme.textGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick replies ──────────────────────────────────────────────────────────

  Widget _buildQuickReplies() {
    const replies = [
      'Confirm shift',
      'Running late',
      'Task completed!',
      'Need help',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: replies
              .map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: () => _sendMessage(t),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(t, style: const TextStyle(fontSize: 12)),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ── Input bar ──────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderGrey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppTheme.borderGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppTheme.borderGrey),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_msgController.text),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
