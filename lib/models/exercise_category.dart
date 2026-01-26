// Exercise Category Model
class ExerciseCategory {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final String icon; // Icon name or path
  final int order; // Display order

  ExerciseCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.icon,
    required this.order,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'description': description,
      'icon': icon,
      'order': order,
    };
  }

  // Create from JSON
  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    return ExerciseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      order: json['order'] as int,
    );
  }

  // Create a copy with modifications
  ExerciseCategory copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? description,
    String? icon,
    int? order,
  }) {
    return ExerciseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      order: order ?? this.order,
    );
  }
}
