// lib/widgets/chat_widgets.dart

import 'package:flutter/material.dart';
import 'package:minddrift/models/chat_message.dart';

// A stylish, animated Floating Action Button for chat.
class ChatFab extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onPressed;

  const ChatFab({
    super.key,
    required this.unreadCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF4A00E0),
      splashColor: Colors.purple.shade300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 28),
          if (unreadCount > 0)
            Positioned(
              top: -4,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// The main chat panel that slides up from the bottom.
class ChatPanel extends StatefulWidget {
  // You would pass the stream of messages from Firebase here
  final Stream<List<ChatMessage>> messagesStream;
  final String currentUserId;
  final Function(String) onSendMessage;

  const ChatPanel({
    super.key,
    required this.messagesStream,
    required this.currentUserId,
    required this.onSendMessage,
  });

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSendMessage(_controller.text.trim());
      _controller.clear();
      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Room Chat',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Message List
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: widget.messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Be the first to say something!',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Shows latest messages at the bottom
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatMessageBubble(
                      message: message,
                      isFromCurrentUser: message.isFromUser(widget.currentUserId),
                    );
                  },
                );
              },
            ),
          ),
          // Input Area
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF8E2DE2),
                padding: const EdgeInsets.all(12),
              ),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// A styled message bubble for individual chat messages.
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isFromCurrentUser;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system) {
      return _buildSystemMessage(context);
    }
    return _buildUserMessage(context);
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        message.content,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.purple.shade200,
          fontStyle: FontStyle.italic,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildUserMessage(BuildContext context) {
    final alignment = isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isFromCurrentUser ? const Color(0xFF8E2DE2) : Colors.grey.shade800;
    final textColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Sender's Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              message.senderName,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 2),
          // Bubble
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.content,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
          const SizedBox(height: 4),
          // Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              message.formattedTime,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
