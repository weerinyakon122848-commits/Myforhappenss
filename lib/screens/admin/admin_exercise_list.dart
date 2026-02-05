import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_data_provider.dart';
import '../../models/exercise_card.dart';
import 'admin_exercise_form.dart';

class AdminExerciseListScreen extends StatelessWidget {
  const AdminExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'จัดการ Exercise Cards',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          final categories = provider.categories;
          final relaxationActivities = provider.relaxationActivities;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ...categories.map(
                (category) => _buildCategorySection(
                  context,
                  provider,
                  category.id,
                  category.name,
                  Icons.category,
                ),
              ),
              const Divider(height: 40, thickness: 2),
              const Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text(
                  "กิจกรรมผ่อนคลาย",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E35B1),
                  ),
                ),
              ),
              ...relaxationActivities.map(
                (activity) => _buildCategorySection(
                  context,
                  provider,
                  activity.id,
                  activity.name,
                  Icons.spa,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminExerciseFormScreen(),
            ),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5E35B1),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่ม Exercise'),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    ExerciseCard card,
    AppDataProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: card.youtubeId != null
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            card.youtubeId != null ? Icons.play_circle : Icons.image,
            color: card.youtubeId != null ? Colors.red : Colors.blue,
            size: 30,
          ),
        ),
        title: Text(
          card.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          card.subtitle,
          style: const TextStyle(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminExerciseFormScreen(card: card),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ลบ Exercise Card'),
                    content: Text('คุณต้องการลบ "${card.title}" หรือไม่?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.deleteExerciseCard(card.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ลบสำเร็จ')),
                          );
                        },
                        child: const Text(
                          'ลบ',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    AppDataProvider provider,
    String categoryId,
    String categoryName,
    IconData icon,
  ) {
    final cards = provider.getCardsByCategory(categoryId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E35B1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF5E35B1), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cards.length} cards',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Exercise Cards
        if (cards.isEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text(
                'ไม่มี Exercise Cards',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...cards.map((card) => _buildExerciseCard(context, card, provider)),

        const SizedBox(height: 20),
      ],
    );
  }
}
