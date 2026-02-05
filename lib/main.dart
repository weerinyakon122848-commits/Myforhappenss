import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tanon.dart';
import 'tanang.dart';
import 'tayorn.dart';
import 'condition_screen.dart';
import 'widgets/fade_in_up.dart';
import 'splash_screen.dart';
import 'providers/app_data_provider.dart';
import 'screens/admin/admin_login_screen.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppDataProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Senior Exercise App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: GoogleFonts.kanitTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFFFBEF),
      ),
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Section
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: _buildHeroSection(context),
                    ),

                    const SizedBox(height: 20),

                    // 2. Section: บริบทการออกกำลังกาย
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Consumer<AppDataProvider>(
                          builder: (context, provider, child) {
                            return Row(
                              children: [
                                const Text(
                                  "บริบทการออกกำลังกาย",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.pinkAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "${provider.categories.length}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // *** จุดที่แก้ไข: เรียกใช้ฟังก์ชัน List ให้ถูกต้อง ***
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildExerciseContextList(context),
                    ),

                    const SizedBox(height: 20),

                    // 3. Section: อาการ
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildConditionSection(context),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
              // 4. Section: ผ่อนคลาย (ขยายให้เต็มพื้นที่ที่เหลือ)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: _buildRelaxationSection(context),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 5. Custom Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeInUp(
              delay: const Duration(milliseconds: 800),
              offset: 100,
              child: _buildBottomBar(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeroSection(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        // Navigate to admin login after long press
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
        );
      },
      child: const _HeroCarousel(),
    );
  }

  // *** แก้ไขฟังก์ชันนี้: ใช้ Provider แทน hard-coded data ***
  Widget _buildExerciseContextList(BuildContext context) {
    final provider = Provider.of<AppDataProvider>(context);
    final categories = provider.categories;

    // Color mapping for categories
    final colorMap = {
      'tanon': Colors.yellow[100]!,
      'tanang': Colors.pink[100]!,
      'tayorn': Colors.purple[100]!,
    };

    // Icon mapping for categories
    final iconMap = {
      'tanon': Icons.bed,
      'tanang': Icons.chair_alt,
      'tayorn': Icons.accessibility,
    };

    // Screen mapping for categories
    final screenMap = {
      'tanon': const TanonScreen(),
      'tanang': const TanangScreen(),
      'tayorn': const TayornScreen(),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                final screen = screenMap[category.id];
                if (screen != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => screen),
                  );
                }
              },
              child: _buildContextCard(
                category.name,
                category.nameEn,
                colorMap[category.id] ?? Colors.grey[100]!,
                iconMap[category.id] ?? Icons.fitness_center,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContextCard(
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: 140,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(icon, size: 40, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ConditionScreen(
                title: "ปวดเมื่อย",
                subtitle: "Aches and pains",
                themeColor: Color(0xFFFFF3CD),
                icon: Icons.healing,
                categoryId: 'aches',
              ),
            ),
          );
        },
        child: _buildConditionCard(
          "ปวดเมื่อย",
          "Aches and pains",
          const Color.fromARGB(255, 155, 202, 230),
          Icons.healing,
          imagePath: 'assets/images/aches_sticker.png',
        ),
      ),
    );
  }

  Widget _buildConditionCard(
    String title,
    String subtitle,
    Color color,
    IconData icon, {
    String? imagePath,
  }) {
    return Container(
      height: 140, // Height might need adjustment for the image
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Text Content
          Positioned(
            top: 0,
            left: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Icon: If image exists, bottom-left. Else bottom-right.
          Positioned(
            bottom: 0,
            left: imagePath != null ? 40 : null,
            right: imagePath != null ? null : 0,
            child: Transform.rotate(
              angle: imagePath != null ? -0.5 : 0,
              child: Icon(
                icon,
                size: imagePath != null ? 60 : 50,
                color: Colors.black12,
              ),
            ),
          ),

          // Image: If exists, on the right
          if (imagePath != null)
            Positioned(
              right: 15,
              bottom: -20,
              top: -50, // Allow it to perform a bit 'out' of box if needed
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRelaxationSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 239, 242, 193),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/relaxation_illustration.png',
              fit: BoxFit.fitWidth,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Container
                Container(
                  margin: const EdgeInsets.only(left: 20, bottom: 25),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    "ผ่อนคลาย",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Relax Items Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRelaxItem(context, "รำไทชิ", Icons.self_improvement),
                    _buildRelaxItem(context, "โยคะ", Icons.spa),
                    _buildRelaxItem(
                      context,
                      "ยืดเหยียด",
                      Icons.accessibility_new,
                    ),
                  ],
                ),

                // Add padding to ensure Column has height for background and Positoned image
                const SizedBox(height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelaxItem(BuildContext context, String title, IconData icon) {
    return InkWell(
      onTap: () {
        String categoryId;
        String subtitle;
        Color themeColor;

        if (title == "รำไทชิ") {
          categoryId = 'taichi';
          subtitle = "Relaxation & Mindfulness";
          themeColor = const Color(0xFFFFC1E3);
        } else if (title == "โยคะ") {
          categoryId = 'yoga';
          subtitle = "Mind & Body Balance";
          themeColor = const Color(0xFFFFCCBC);
        } else {
          categoryId = 'stretching';
          subtitle = "Flexibility & Recovery";
          themeColor = const Color(0xFFE1BEE7);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConditionScreen(
              title: title,
              subtitle: subtitle,
              themeColor: themeColor,
              icon: icon,
              categoryId: categoryId,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 45, color: const Color(0xFFFF4081)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SizedBox(
      // Changed to SizedBox for explicit size control
      height:
          100, // Increased height to prevent any clipping of the floating button
      child: Stack(
        clipBehavior: Clip.none, // Crucial: Allow button to overflow
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
            bottom:
                25, // Lifted significantly to ensure it's "in front" and overlapping
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8DE8B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.2,
                    ), // Added shadow to button for depth
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppDataProvider>(context);
    final carouselImages = provider.getActiveCarouselImages();
    return Container(
      width: double.infinity,
      height: 180, // Shorter as requested
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ), // Wider as requested
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: carouselImages.length,
              onPageChanged: (index) {
                setState(() {
                  _current = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  carouselImages[index].imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade400,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.white54,
                    ),
                  ),
                );
              },
            ),

            // Indicators
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: carouselImages.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(
                      entry.key,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(
                          alpha: _current == entry.key ? 0.9 : 0.4,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
