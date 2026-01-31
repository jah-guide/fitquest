// fitquest/lib/models/exercise.dart
class Exercise {
  final int? id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final bool isSynced;
  final DateTime createdAt;

  Exercise({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.isSynced = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      isSynced: map['isSynced'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
