// Exercise Card Model
class ExerciseCard {
  final String id;
  final String title;
  final String subtitle;
  final String? thumbnailPath; // Path to local image asset
  final String? youtubeId; // YouTube video ID
  final String categoryId; // Reference to category

  ExerciseCard({
    required this.id,
    required this.title,
    required this.subtitle,
    this.thumbnailPath,
    this.youtubeId,
    required this.categoryId,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'thumbnailPath': thumbnailPath,
      'youtubeId': youtubeId,
      'categoryId': categoryId,
    };
  }

  // Create from JSON
  factory ExerciseCard.fromJson(Map<String, dynamic> json) {
    return ExerciseCard(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      youtubeId: json['youtubeId'] as String?,
      categoryId: json['categoryId'] as String,
    );
  }

  // Create a copy with modifications
  ExerciseCard copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? thumbnailPath,
    String? youtubeId,
    String? categoryId,
  }) {
    return ExerciseCard(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      youtubeId: youtubeId ?? this.youtubeId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
