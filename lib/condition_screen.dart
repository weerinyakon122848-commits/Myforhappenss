import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/exercise_card.dart';
import 'widgets/fade_in_up.dart';
import 'exercise_detail_screen.dart';
import 'providers/app_data_provider.dart';

class ConditionScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color themeColor;
  final IconData icon;
  final String categoryId;

  const ConditionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.icon,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              // --- Header ---
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Icon(icon, size: 40, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- Tab ---
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "แนะนำ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // --- Content List ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Consumer<AppDataProvider>(
                    builder: (context, provider, child) {
                      final exercises = provider.getCardsByCategory(categoryId);

                      if (exercises.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 60,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "ยังไม่มีท่าออกกำลังกาย\nในหมวดหมู่นี้",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final card = exercises[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: FadeInUp(
                              delay: Duration(milliseconds: 100 * (index + 1)),
                              child: ExerciseCard(
                                type: card.contentType == 'youtube'
                                    ? 'youtube'
                                    : 'image',
                                title: card.title,
                                subtitle: card.subtitle,
                                duration: 'แนะนำ',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExerciseDetailScreen(
                                        category: title,
                                        title: card.title,
                                        description: card.subtitle,
                                        youtubeVideoId: card.youtubeId,
                                        image: card.thumbnailPath,
                                        contentType: card.contentType,
                                        fullContent: card.fullContent,
                                      ),
                                    ),
                                  );
                                },
                                videoId: card.youtubeId ?? '',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // --- Home Button ---
          Positioned(
            bottom: 0,
            child: FadeInUp(
              delay: const Duration(milliseconds: 800),
              offset: 100,
              child: SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
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
                      bottom: 25,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6EE9C),
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
                            size: 40,
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
