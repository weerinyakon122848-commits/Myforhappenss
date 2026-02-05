import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/fade_in_up.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String category;
  final String title;
  final String description;
  final String? youtubeVideoId; // Make optional
  final String? image; // Add image path
  final String contentType; // Content type: youtube/image/google
  final String? fullContent; // Full content for Google type

  const ExerciseDetailScreen({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    this.youtubeVideoId, // No longer required
    this.image,
    this.contentType = 'youtube', // Default to youtube
    this.fullContent,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  YoutubePlayerController? _controller;
  bool _isPlayerSupported = false;

  @override
  void initState() {
    super.initState();
    // Only init player if video ID is provided
    if (widget.youtubeVideoId != null &&
        widget.youtubeVideoId!.isNotEmpty &&
        !kIsWeb &&
        (Platform.isAndroid || Platform.isIOS)) {
      _isPlayerSupported = true;
      try {
        _controller = YoutubePlayerController(
          initialVideoId: widget.youtubeVideoId!,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      } catch (e) {
        debugPrint("Error init player: $e");
        _isPlayerSupported = false;
      }
    } else {
      _isPlayerSupported = false; // Windows, Web, Linux, MacOS
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _launchYouTube() async {
    if (widget.youtubeVideoId == null) return;
    final Uri url = Uri.parse(
      'https://www.youtube.com/watch?v=${widget.youtubeVideoId}',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Stack(
        children: [
          // 1. Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.pink.shade100, Colors.white],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 2. Header (Category)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Spacer to ensure X button isn't covered if we used a Row (but we use Stack for X)
                    ],
                  ),
                ),

                // 3. Main Content
                Expanded(
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 10, 20, 80),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // --- MEDIA SECTION (VIDEO OR IMAGE) ---
                              Container(
                                color: Colors.black,
                                height: 200,
                                child:
                                    (widget.youtubeVideoId != null &&
                                        widget.youtubeVideoId!.isNotEmpty)
                                    ? (_isPlayerSupported && _controller != null
                                          ? YoutubePlayer(
                                              controller: _controller!,
                                              showVideoProgressIndicator: true,
                                              progressIndicatorColor:
                                                  Colors.pink,
                                            )
                                          : Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // 1. Thumbnail Image (Custom Image OR YouTube Default)
                                                SizedBox.expand(
                                                  child: widget.image != null
                                                      ? (widget.image!
                                                                .startsWith(
                                                                  'http',
                                                                )
                                                            ? Image.network(
                                                                widget.image!,
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder:
                                                                    (
                                                                      context,
                                                                      error,
                                                                      stackTrace,
                                                                    ) => Image.network(
                                                                      'https://img.youtube.com/vi/${widget.youtubeVideoId!.split('&').first}/hqdefault.jpg',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                              )
                                                            : (widget.image!
                                                                      .startsWith(
                                                                        'assets',
                                                                      )
                                                                  ? Image.asset(
                                                                      widget
                                                                          .image!,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : Image.memory(
                                                                      base64Decode(
                                                                        widget
                                                                            .image!,
                                                                      ),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )))
                                                      : Image.network(
                                                          'https://img.youtube.com/vi/${widget.youtubeVideoId!.split('&').first}/hqdefault.jpg',
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Container(
                                                                  color: Colors
                                                                      .black,
                                                                );
                                                              },
                                                        ),
                                                ),

                                                // 2. Black Overlay (for readability)
                                                Container(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.4),
                                                ),

                                                // 3. Play Button & Action
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.play_circle_fill,
                                                      color: Colors.white,
                                                      size: 60,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    ElevatedButton.icon(
                                                      onPressed: _launchYouTube,
                                                      icon: const Icon(
                                                        Icons.open_in_new,
                                                        size: 18,
                                                      ),
                                                      label: const Text(
                                                        "เปิดดูใน Youtube",
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 10,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                30,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ))
                                    : (widget.image != null
                                          ? (widget.image!.startsWith('http')
                                                ? Image.network(
                                                    widget.image!,
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return const Center(
                                                            child: Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          );
                                                        },
                                                  )
                                                : (widget.image!.startsWith(
                                                        'assets',
                                                      )
                                                      ? Image.asset(
                                                          widget.image!,
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return const Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .image_not_supported,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                );
                                                              },
                                                        )
                                                      : Image.memory(
                                                          base64Decode(
                                                            widget.image!,
                                                          ),
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return const Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .image_not_supported,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                );
                                                              },
                                                        )))
                                          : const Center(
                                              child: Icon(
                                                Icons
                                                    .image_not_supported, // Fallback if no media at all
                                                color: Colors.white,
                                              ),
                                            )),
                              ),

                              // --- CONTENT ---
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 15),

                                    // Show full content for Google type, otherwise show description
                                    if (widget.contentType == 'google' &&
                                        widget.fullContent != null)
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.pink.shade50.withValues(
                                            alpha: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Text(
                                          widget.fullContent!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade800,
                                            height: 1.6,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.pink.shade50.withValues(
                                            alpha: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Text(
                                          widget.description,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade800,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 30),
                                    Center(
                                      child: Opacity(
                                        opacity: 0.8,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.accessibility_new_rounded,
                                              size: 60,
                                              color: Colors.pink.shade200,
                                            ),
                                            const SizedBox(width: 20),
                                            Icon(
                                              Icons.self_improvement_rounded,
                                              size: 60,
                                              color: Colors.green.shade200,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. X Close Button (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.black54, size: 24),
              ),
            ),
          ),

          // 5. Bottom Home Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeInUp(
              delay: const Duration(milliseconds: 500),
              offset: 50,
              child: SizedBox(
                height: 80,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(50),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8DE8B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
