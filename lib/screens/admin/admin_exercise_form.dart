import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_data_provider.dart';
import '../../models/exercise_card.dart' as model;

class AdminExerciseFormScreen extends StatefulWidget {
  final model.ExerciseCard? card;

  const AdminExerciseFormScreen({super.key, this.card});

  @override
  State<AdminExerciseFormScreen> createState() =>
      _AdminExerciseFormScreenState();
}

class _AdminExerciseFormScreenState extends State<AdminExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _youtubeIdController;
  late TextEditingController _thumbnailPathController;
  String? _selectedCategoryId;

  bool get isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card?.title ?? '');
    _subtitleController = TextEditingController(
      text: widget.card?.subtitle ?? '',
    );
    _youtubeIdController = TextEditingController(
      text: widget.card?.youtubeId ?? '',
    );
    _thumbnailPathController = TextEditingController(
      text: widget.card?.thumbnailPath ?? '',
    );
    _selectedCategoryId = widget.card?.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _youtubeIdController.dispose();
    _thumbnailPathController.dispose();
    super.dispose();
  }

  // Extract YouTube ID from URL
  String? _extractYouTubeId(String input) {
    if (input.isEmpty) return null;

    input = input.trim();

    // If it's already just an ID (no slashes or special chars), return it
    if (!input.contains('/') && !input.contains('?') && !input.contains('&')) {
      return input;
    }

    // Try to extract from various YouTube URL formats
    final patterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\s]+)'),
      RegExp(r'youtube\.com\/embed\/([^&\s]+)'),
      RegExp(r'youtube\.com\/v\/([^&\s]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return input; // Return as-is if no pattern matches
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppDataProvider>(context, listen: false);

      // Validate that either YouTube ID or Thumbnail Path is provided
      if (_youtubeIdController.text.isEmpty &&
          _thumbnailPathController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'กรุณาใส่ YouTube URL หรือ Thumbnail Path อย่างน้อย 1 อย่าง',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Extract YouTube ID from URL if provided
      final youtubeId = _extractYouTubeId(_youtubeIdController.text);

      final exerciseCard = model.ExerciseCard(
        id: isEditing
            ? widget.card!.id
            : 'card_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        categoryId: _selectedCategoryId!,
        youtubeId: youtubeId,
        thumbnailPath: _thumbnailPathController.text.trim().isEmpty
            ? null
            : _thumbnailPathController.text.trim(),
      );

      if (isEditing) {
        provider.updateExerciseCard(exerciseCard);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('แก้ไขสำเร็จ')));
      } else {
        provider.addExerciseCard(exerciseCard);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('เพิ่มสำเร็จ')));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          isEditing ? 'แก้ไข Exercise Card' : 'เพิ่ม Exercise Card',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Title Field
                _buildTextField(
                  controller: _titleController,
                  label: 'ชื่อท่าออกกำลังกาย',
                  hint: 'เช่น ท่านอนยกขา',
                  icon: Icons.title,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณาใส่ชื่อท่าออกกำลังกาย';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Subtitle Field
                _buildTextField(
                  controller: _subtitleController,
                  label: 'คำอธิบาย',
                  hint: 'เช่น Thai PBS หรือ คำแนะนำเพิ่มเติม',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณาใส่คำอธิบาย';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'หมวดหมู่',
                      prefixIcon: Icon(
                        Icons.category,
                        color: Color(0xFF5E35B1),
                      ),
                      border: InputBorder.none,
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        enabled: false,
                        value: 'header_categories',
                        child: Text(
                          '--- หมวดหมู่ ---',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ...provider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }),
                      const DropdownMenuItem<String>(
                        enabled: false,
                        value: 'header_activities',
                        child: Text(
                          '--- กิจกรรมผ่อนคลาย ---',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ...provider.relaxationActivities.map((activity) {
                        return DropdownMenuItem(
                          value: activity.id,
                          child: Text(activity.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'กรุณาเลือกหมวดหมู่';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // YouTube URL Field
                _buildTextField(
                  controller: _youtubeIdController,
                  label: 'YouTube URL (ถ้ามี)',
                  hint: 'เช่น https://www.youtube.com/watch?v=dvhNOKRrOjk',
                  icon: Icons.video_library,
                ),
                const SizedBox(height: 20),

                // Thumbnail Path Field
                _buildTextField(
                  controller: _thumbnailPathController,
                  label: 'Thumbnail Path (ถ้ามี)',
                  hint: 'เช่น assets/images/exercise.png',
                  icon: Icons.image,
                ),
                const SizedBox(height: 10),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'ใส่ YouTube URL หรือ Thumbnail Path อย่างน้อย 1 อย่าง',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      isEditing ? 'บันทึกการแก้ไข' : 'เพิ่ม Exercise Card',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF5E35B1)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
