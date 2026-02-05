// Exercise Card Model
class ExerciseCard {
  final String id;
  final String title;
  final String subtitle;
  final String? thumbnailPath; // Path to local image asset
  final String? youtubeId; // YouTube video ID
  final String categoryId; // Reference to category
  final String contentType; // Content type: 'youtube', 'image', 'google'
  final String? fullContent; // Long-form content for Google type

  ExerciseCard({
    required this.id,
    required this.title,
    required this.subtitle,
    this.thumbnailPath,
    this.youtubeId,
    required this.categoryId,
    this.contentType = 'youtube', // Default to youtube for backward compatibility
    this.fullContent,
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
      'contentType': contentType,
      'fullContent': fullContent,
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
      contentType: json['contentType'] as String? ?? 'youtube', // Default for old data
      fullContent: json['fullContent'] as String?,
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
    String? contentType,
    String? fullContent,
  }) {
    return ExerciseCard(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      youtubeId: youtubeId ?? this.youtubeId,
      categoryId: categoryId ?? this.categoryId,
      contentType: contentType ?? this.contentType,
      fullContent: fullContent ?? this.fullContent,
    );
  }
}
