// lib/widgets/draggable_chat_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';

class DraggableChatWidget extends StatefulWidget {
  final String roomId;
  final String roomName;

  const DraggableChatWidget({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<DraggableChatWidget> createState() => _DraggableChatWidgetState();
}

class _DraggableChatWidgetState extends State<DraggableChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final chatMessage = ChatMessage(
        id: '', // Will be set by Firestore
        roomId: widget.roomId,
        senderId: user.uid,
        senderName: user.displayName ?? 'Anonymous',
        senderAvatar: user.photoURL,
        content: message,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('chat_messages')
          .add(chatMessage.toFirestore());

      _messageController.clear();
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[700],
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue[600] : Colors.grey[800],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    message.content,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[600],
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  Widget _buildChatPopup(BuildContext context, ChatProvider chatProvider, Size screenSize) {
    // Calculate popup position based on button position
    final buttonX = chatProvider.buttonPosition.dx * screenSize.width;
    final buttonY = chatProvider.buttonPosition.dy * screenSize.height;
    
    // Chat popup dimensions
    const chatWidth = 320.0;
    const chatHeight = 400.0;
    const buttonSize = 56.0;
    
    // Calculate popup position to appear next to button
    double popupLeft = buttonX + buttonSize + 8;
    double popupTop = buttonY - chatHeight / 2;
    
    // Adjust if popup would go off screen
    if (popupLeft + chatWidth > screenSize.width) {
      popupLeft = buttonX - chatWidth - 8; // Show on left side of button
    }
    if (popupTop < 0) {
      popupTop = 8; // Minimum top padding
    }
    if (popupTop + chatHeight > screenSize.height) {
      popupTop = screenSize.height - chatHeight - 8; // Maximum bottom padding
    }
    
    return Positioned(
      left: popupLeft,
      top: popupTop,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: chatWidth,
          height: chatHeight,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chat header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.roomName} Chat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: chatProvider.collapseChat,
                      icon: const Icon(Icons.close, color: Colors.white),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              
              // Messages list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chat_messages')
                      .where('roomId', isEqualTo: widget.roomId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading messages: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final messages = snapshot.data!.docs
                        .map((doc) => ChatMessage.fromFirestore(doc))
                        .toList()
                      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildMessageBubble(message);
                      },
                    );
                  },
                ),
              ),
              
              // Message input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[700],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        onPressed: _isLoading ? null : _sendMessage,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final screenSize = MediaQuery.of(context).size;
        final safeArea = MediaQuery.of(context).padding;
        
        // Calculate actual button position
        final buttonX = chatProvider.buttonPosition.dx * (screenSize.width - 56);
        final buttonY = chatProvider.buttonPosition.dy * (screenSize.height - safeArea.top - safeArea.bottom - 56) + safeArea.top;
        
        return Stack(
          children: [
            // Chat popup (if expanded)
            if (chatProvider.isChatExpanded)
              _buildChatPopup(context, chatProvider, screenSize),
            
            // Draggable chat button
            Positioned(
              left: buttonX,
              top: buttonY,
              child: Draggable(
                feedback: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.blue[600]?.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.chat, color: Colors.white, size: 24),
                  ),
                ),
                childWhenDragging: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue[600]?.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.chat, color: Colors.white54, size: 24),
                ),
                onDragEnd: (details) {
                  // Convert global position to relative position
                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.offset);
                  
                  // Calculate relative position (0.0 to 1.0)
                  final relativeX = (localPosition.dx / (screenSize.width - 56)).clamp(0.0, 1.0);
                  final relativeY = ((localPosition.dy - safeArea.top) / (screenSize.height - safeArea.top - safeArea.bottom - 56)).clamp(0.0, 1.0);
                  
                  chatProvider.updateButtonPosition(Offset(relativeX, relativeY));
                },
                child: GestureDetector(
                  onTap: chatProvider.toggleChat,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.chat, color: Colors.white, size: 24),
                        ),
                        // Unread message indicator (for future use)
                        // Positioned(
                        //   top: 8,
                        //   right: 8,
                        //   child: Container(
                        //     width: 12,
                        //     height: 12,
                        //     decoration: BoxDecoration(
                        //       color: Colors.red,
                        //       borderRadius: BorderRadius.circular(6),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
