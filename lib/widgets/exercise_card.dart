import 'dart:convert';
import 'package:flutter/material.dart';

class ExerciseCard extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final String? duration;
  final String? videoId; // Optional video ID for thumbnail
  final String? image; // Optional local image path
  final VoidCallback onTap;

  const ExerciseCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.duration,
    this.videoId,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    // Generate thumbnail URL if videoId is present
    // First split to handle any &t=... params just in case (though we clean it elsewhere too)
    final String? thumbnail = videoId != null
        ? 'https://img.youtube.com/vi/${videoId!.split('&').first}/mqdefault.jpg'
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            type == 'youtube'
                                ? Icons.play_circle_fill
                                : Icons.search,
                            size: 20,
                            color: type == 'youtube' ? Colors.red : Colors.blue,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            type == 'youtube' ? 'YouTube' : 'Google',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          if (duration != null) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              duration!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Thumbnail Image
                Container(
                  width: 120, // Slightly wider for 16:9 feel
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: image != null
                        ? (image!.startsWith('http')
                              ? Image.network(
                                  image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.black12,
                                      ),
                                )
                              : (image!.startsWith('assets')
                                    ? Image.asset(
                                        image!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.black12,
                                                ),
                                      )
                                    : Image.memory(
                                        base64Decode(image!),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.black12,
                                                ),
                                      )))
                        : (thumbnail != null
                              ? Image.network(
                                  thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.black12,
                                      ),
                                )
                              : const Icon(
                                  Icons.image,
                                  color: Colors.black12,
                                  size: 40,
                                )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
