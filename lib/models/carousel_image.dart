// Carousel Image Model
class CarouselImage {
  final String id;
  final String imagePath; // Path to local image asset
  final int order; // Display order
  final bool isActive; // Whether to show this image

  CarouselImage({
    required this.id,
    required this.imagePath,
    required this.order,
    this.isActive = true,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'order': order,
      'isActive': isActive,
    };
  }

  // Create from JSON
  factory CarouselImage.fromJson(Map<String, dynamic> json) {
    return CarouselImage(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      order: json['order'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  // Create a copy with modifications
  CarouselImage copyWith({
    String? id,
    String? imagePath,
    int? order,
    bool? isActive,
  }) {
    return CarouselImage(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}
