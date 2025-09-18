// lib/models/avatar.dart

import 'dart:math';

// A simple class to hold avatar data
class Avatar {
  final String id;
  final String svgPath;
  final String packId;
  final bool isLocked;

  const Avatar({
    required this.id, 
    required this.svgPath,
    this.packId = 'free',
    this.isLocked = false,
  });

  Avatar copyWith({
    String? id,
    String? svgPath,
    String? packId,
    bool? isLocked,
  }) {
    return Avatar(
      id: id ?? this.id,
      svgPath: svgPath ?? this.svgPath,
      packId: packId ?? this.packId,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

// A predefined list of available avatars
class Avatars {
  // Free avatars (always available)
  static final List<Avatar> _freeAvatars = [
    const Avatar(id: 'bear', svgPath: 'assets/avatars/bear.svg', packId: 'free'),
    const Avatar(id: 'cat', svgPath: 'assets/avatars/cat.svg', packId: 'free'),
    const Avatar(id: 'dog', svgPath: 'assets/avatars/dog.svg', packId: 'free'),
    const Avatar(id: 'fox', svgPath: 'assets/avatars/fox.svg', packId: 'free'),
    const Avatar(id: 'lion', svgPath: 'assets/avatars/lion.svg', packId: 'free'),
    const Avatar(id: 'panda', svgPath: 'assets/avatars/panda.svg', packId: 'free'),
    const Avatar(id: 'rabbit', svgPath: 'assets/avatars/rabbit.svg', packId: 'free'),
    const Avatar(id: 'tiger', svgPath: 'assets/avatars/tiger.svg', packId: 'free'),
  ];

  // Premium Robot Pack (2500 gems)
  static final List<Avatar> _robotPackAvatars = [
    const Avatar(id: 'robot_01', svgPath: 'assets/avatars/robot_01.svg', packId: 'pack_robots', isLocked: true),
    const Avatar(id: 'robot_02', svgPath: 'assets/avatars/robot_02.svg', packId: 'pack_robots', isLocked: true),
    const Avatar(id: 'robot_03', svgPath: 'assets/avatars/robot_03.svg', packId: 'pack_robots', isLocked: true),
    const Avatar(id: 'robot_04', svgPath: 'assets/avatars/robot_04.svg', packId: 'pack_robots', isLocked: true),
    const Avatar(id: 'robot_05', svgPath: 'assets/avatars/robot_05.svg', packId: 'pack_robots', isLocked: true),
    const Avatar(id: 'robot_06', svgPath: 'assets/avatars/robot_06.svg', packId: 'pack_robots', isLocked: true),
  ];

  // Get all free avatars (always available)
  static List<Avatar> get freeAvatars => _freeAvatars;

  // Get all robot pack avatars
  static List<Avatar> get robotPackAvatars => _robotPackAvatars;

  // Get all avatars (free + premium)
  static List<Avatar> get all => [..._freeAvatars, ..._robotPackAvatars];

  /// Get available avatars based on user's owned packs
  static List<Avatar> getAvailableAvatars(List<String> ownedPacks) {
    final available = <Avatar>[];
    
    // Always add free avatars
    available.addAll(_freeAvatars);
    
    // Add robot pack avatars if owned
    if (ownedPacks.contains('pack_robots')) {
      available.addAll(_robotPackAvatars.map((avatar) => avatar.copyWith(isLocked: false)));
    } else {
      // Add locked robot pack avatars for display
      available.addAll(_robotPackAvatars);
    }
    
    return available;
  }

  /// Get avatars from a specific pack
  static List<Avatar> getPackAvatars(String packId) {
    switch (packId) {
      case 'free':
        return _freeAvatars;
      case 'pack_robots':
        return _robotPackAvatars;
      default:
        return [];
    }
  }

  static String getRandomAvatarId() {
    final random = Random();
    return _freeAvatars[random.nextInt(_freeAvatars.length)].id;
  }

  static String getPathFromId(String id) {
    try {
      return all.firstWhere((avatar) => avatar.id == id).svgPath;
    } catch (e) {
      // Return a default avatar if the id is not found
      return _freeAvatars.first.svgPath;
    }
  }

  /// Check if an avatar is locked for the user
  static bool isAvatarLocked(String avatarId, List<String> ownedPacks) {
    try {
      final avatar = all.firstWhere((a) => a.id == avatarId);
      if (avatar.packId == 'free') return false;
      return !ownedPacks.contains(avatar.packId);
    } catch (e) {
      return false; // If avatar not found, assume unlocked
    }
  }
}
