// lib/widgets/global_chat_overlay.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'draggable_chat_widget.dart';

class GlobalChatOverlay extends StatelessWidget {
  final String roomId;
  final String roomName;

  const GlobalChatOverlay({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  Widget build(BuildContext context) {
    // Set the current room ID in the chat provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().setRoomId(roomId);
    });

    return DraggableChatWidget(
      roomId: roomId,
      roomName: roomName,
    );
  }
}
