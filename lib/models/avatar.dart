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

  // Premium Batch1 Pack (2500 gems)
  static final List<Avatar> _batch1PackAvatars = [
    const Avatar(id: 'batch1_01', svgPath: 'assets/avatars/batch1_01.svg', packId: 'pack_batch1', isLocked: true),
    const Avatar(id: 'batch1_02', svgPath: 'assets/avatars/batch1_02.svg', packId: 'pack_batch1', isLocked: true),
    const Avatar(id: 'batch1_03', svgPath: 'assets/avatars/batch1_03.svg', packId: 'pack_batch1', isLocked: true),
    const Avatar(id: 'batch1_04', svgPath: 'assets/avatars/batch1_04.svg', packId: 'pack_batch1', isLocked: true),
    const Avatar(id: 'batch1_05', svgPath: 'assets/avatars/batch1_05.svg', packId: 'pack_batch1', isLocked: true),
    const Avatar(id: 'batch1_06', svgPath: 'assets/avatars/batch1_06.svg', packId: 'pack_batch1', isLocked: true),
    const Avatar(id: 'batch1_07', svgPath: 'assets/avatars/batch1_07.svg', packId: 'pack_batch1', isLocked: true),
    const Avatar(id: 'batch1_08', svgPath: 'assets/avatars/batch1_08.svg', packId: 'pack_batch1', isLocked: true),
    const Avatar(id: 'batch1_09', svgPath: 'assets/avatars/batch1_09.svg', packId: 'pack_batch1', isLocked: true),
  ];

  // Get all free avatars (always available)
  static List<Avatar> get freeAvatars => _freeAvatars;

  // Get all batch1 pack avatars
  static List<Avatar> get batch1PackAvatars => _batch1PackAvatars;

  // Get all avatars (free + premium)
  static List<Avatar> get all => [..._freeAvatars, ..._batch1PackAvatars];

  /// Get available avatars based on user's owned packs
  static List<Avatar> getAvailableAvatars(List<String> ownedPacks) {
    final available = <Avatar>[];
    
    // Always add free avatars
    available.addAll(_freeAvatars);
    
    // Add batch1 pack avatars if owned
    if (ownedPacks.contains('pack_batch1')) {
      available.addAll(_batch1PackAvatars.map((avatar) => avatar.copyWith(isLocked: false)));
    } else {
      // Add locked batch1 pack avatars for display
      available.addAll(_batch1PackAvatars);
    }
    
    return available;
  }

  /// Get avatars from a specific pack
  static List<Avatar> getPackAvatars(String packId) {
    switch (packId) {
      case 'free':
        return _freeAvatars;
      case 'pack_batch1':
        return _batch1PackAvatars;
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

  /// Get avatar by ID
  static Avatar? getAvatarById(String avatarId) {
    try {
      return all.firstWhere((avatar) => avatar.id == avatarId);
    } catch (e) {
      return null;
    }
  }
}
