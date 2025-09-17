// lib/providers/chat_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  bool _isChatExpanded = false;
  String? _currentRoomId;
  Offset _buttonPosition = const Offset(0.8, 0.8); // Relative position (0.0 to 1.0)
  
  bool get isChatExpanded => _isChatExpanded;
  String? get currentRoomId => _currentRoomId;
  Offset get buttonPosition => _buttonPosition;
  
  void setRoomId(String roomId) {
    if (_currentRoomId != roomId) {
      _currentRoomId = roomId;
      // Reset chat state when switching rooms
      _isChatExpanded = false;
      notifyListeners();
    }
  }
  
  void toggleChat() {
    _isChatExpanded = !_isChatExpanded;
    notifyListeners();
  }
  
  void expandChat() {
    if (!_isChatExpanded) {
      _isChatExpanded = true;
      notifyListeners();
    }
  }
  
  void collapseChat() {
    if (_isChatExpanded) {
      _isChatExpanded = false;
      notifyListeners();
    }
  }
  
  void updateButtonPosition(Offset position) {
    _buttonPosition = position;
    notifyListeners();
  }
  
  void resetButtonPosition() {
    _buttonPosition = const Offset(0.8, 0.8);
    notifyListeners();
  }
  
}
