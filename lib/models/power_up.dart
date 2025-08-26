// lib/models/power_up.dart

class PowerUp {
  final String id;
  final String name;
  final String description;
  final String type;

  PowerUp({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
  });

  factory PowerUp.fromMap(Map<String,dynamic> m) => PowerUp(
    id: m['id'] as String,
    name: m['name'] as String,
    description: m['description'] as String,
    type: m['type'] as String,
  );
}
