class Cow {
  final int id;
  final String cowId;
  final String name;
  final String breed;
  final int lactationMonth;
  final String? imagePath;
  final DateTime createdAt;

  Cow({
    required this.id,
    required this.cowId,
    required this.name,
    required this.breed,
    required this.lactationMonth,
    this.imagePath,
    required this.createdAt,
  });

  factory Cow.fromMap(Map<String, Object?> map) {
    return Cow(
      id: map['id'] as int,
      cowId: map['cow_id'] as String,
      name: map['name'] as String,
      breed: map['breed'] as String,
      lactationMonth: (map['lactation_month'] as int),
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}