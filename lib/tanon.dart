import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/exercise_card.dart';
import 'widgets/fade_in_up.dart';
import 'exercise_detail_screen.dart';
import 'providers/app_data_provider.dart';

class TanonScreen extends StatelessWidget {
  const TanonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              // --- ส่วนหัว ---
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            "ท่านอน",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Exercise in a lying position.",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.fitness_center,
                        size: 40,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- Tab ทั้งหมด ---
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
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 241, 209),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "ทั้งหมด",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // --- รายการวิดีโอ ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 249, 238, 141),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Consumer<AppDataProvider>(
                    builder: (context, provider, child) {
                      final exerciseCards = provider.getCardsByCategory(
                        'tanon',
                      );

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        itemCount: exerciseCards.length,
                        itemBuilder: (context, index) {
                          final card = exerciseCards[index];
                          final delay = Duration(
                            milliseconds: 300 + (index * 100),
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: FadeInUp(
                              delay: delay,
                              child: ExerciseCard(
                                type: card.youtubeId != null
                                    ? 'youtube'
                                    : 'google',
                                title: card.title,
                                subtitle: card.subtitle,
                                duration: card.youtubeId != null
                                    ? '5:24'
                                    : null,
                                image: card.thumbnailPath,
                                videoId: card.youtubeId,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ExerciseDetailScreen(
                                            category: 'ท่านอน',
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

          // --- ปุ่ม Home (กดแล้วกลับหน้าแรก) ---
          Positioned(
            bottom: 0,
            child: FadeInUp(
              delay: const Duration(milliseconds: 800),
              offset: 100,
              child: SizedBox(
                // Changed to SizedBox
                height: 100, // Increased height to accommodate the button fully
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  clipBehavior: Clip.none, // Allow overflow
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
                      bottom: 25, // Lifted higher
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
