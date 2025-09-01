// lib/models/avatar.dart

import 'dart:math';

// A simple class to hold avatar data
class Avatar {
  final String id;
  final String svgPath;

  const Avatar({required this.id, required this.svgPath});
}

// A predefined list of available avatars
class Avatars {
  static final List<Avatar> _avatars = [
    const Avatar(id: 'bear', svgPath: 'assets/avatars/bear.svg'),
    const Avatar(id: 'cat', svgPath: 'assets/avatars/cat.svg'),
    const Avatar(id: 'dog', svgPath: 'assets/avatars/dog.svg'),
    const Avatar(id: 'fox', svgPath: 'assets/avatars/fox.svg'),
    const Avatar(id: 'lion', svgPath: 'assets/avatars/lion.svg'),
    const Avatar(id: 'panda', svgPath: 'assets/avatars/panda.svg'),
    const Avatar(id: 'rabbit', svgPath: 'assets/avatars/rabbit.svg'),
    const Avatar(id: 'tiger', svgPath: 'assets/avatars/tiger.svg'),
  ];

  static List<Avatar> get all => _avatars;

  static String getRandomAvatarId() {
    final _random = Random();
    return _avatars[_random.nextInt(_avatars.length)].id;
  }

  static String getPathFromId(String id) {
    try {
      return _avatars.firstWhere((avatar) => avatar.id == id).svgPath;
    } catch (e) {
      // Return a default avatar if the id is not found
      return _avatars.first.svgPath;
    }
  }
}
