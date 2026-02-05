import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
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
  late TextEditingController _fullContentController;
  String? _selectedCategoryId;
  String _contentType = 'youtube'; // Default content type

  // Image picker
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _base64Image; // Store base64 string
  bool _isUploading = false;

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
    _fullContentController = TextEditingController(
      text: widget.card?.fullContent ?? '',
    );
    _selectedCategoryId = widget.card?.categoryId;
    _contentType = widget.card?.contentType ?? 'youtube';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _youtubeIdController.dispose();
    _thumbnailPathController.dispose();
    _fullContentController.dispose();
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

  // Pick image from device using ImagePicker
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Resize to max 800px width
        imageQuality: 70, // Compress quality to 70%
      );

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();

        // Convert to Base64
        final String base64String = base64Encode(imageBytes);

        setState(() {
          _selectedImageBytes = imageBytes;
          _selectedImageName = image.name;
          _base64Image = base64String;
          // Clean text field as we are using base64
          _thumbnailPathController.text =
              'รูปภาพถูกเลือกแล้ว (${(imageBytes.lengthInBytes / 1024).toStringAsFixed(1)} KB)';
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการเลือกรูปภาพ: $e')),
        );
      }
    }
  }

  void _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppDataProvider>(context, listen: false);

      // Validate based on content type
      if (_contentType == 'youtube' && _youtubeIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณาใส่ YouTube URL สำหรับเนื้อหาประเภท YouTube'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if image is required but not provided (neither selected new image nor existing path)
      if ((_contentType == 'image' || _contentType == 'google') &&
          _selectedImageBytes == null &&
          _thumbnailPathController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณาเลือกรูปภาพ'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_contentType == 'google') {
        if (_fullContentController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กรุณาใส่เนื้อหาสำหรับเนื้อหาประเภท Google'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Start processing
      setState(() {
        _isUploading = true;
      });

      // Determine final thumbnail path
      // 1. If new image selected (_base64Image not null), use it.
      // 2. Else if existing text is NOT empty, use it.
      String? finalThumbnailPath;

      if (_base64Image != null) {
        finalThumbnailPath = _base64Image;
      } else if (_thumbnailPathController.text.isNotEmpty &&
          _thumbnailPathController.text != 'รูปภาพถูกเลือกแล้ว') {
        // Case where we didn't pick a new image, but maybe editing existing one
        // CAUTION: If the text is the placeholder 'รูปภาพถูกเลือกแล้ว', we should ignore it if _base64Image is null.
        finalThumbnailPath = _thumbnailPathController.text.trim();

        if (finalThumbnailPath.startsWith('รูปภาพถูกเลือกแล้ว')) {
          finalThumbnailPath = null;
        }
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
        contentType: _contentType,
        youtubeId: youtubeId,
        thumbnailPath: finalThumbnailPath,
        fullContent: _fullContentController.text.trim().isEmpty
            ? null
            : _fullContentController.text.trim(),
      );

      if (isEditing) {
        await provider.updateExerciseCard(
          exerciseCard,
        ); // Await strictly better
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('แก้ไขสำเร็จ')));
        }
      } else {
        await provider.addExerciseCard(exerciseCard);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('เพิ่มสำเร็จ')));
        }
      }

      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        Navigator.pop(context);
      }
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
                        color: Colors.black.withValues(alpha: 0.05),
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

                // Content Type Selector
                Container(
                  padding: const EdgeInsets.all(15),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ประเภทเนื้อหา',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E35B1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('YouTube'),
                              value: 'youtube',
                              groupValue: _contentType,
                              onChanged: (value) {
                                setState(() {
                                  _contentType = value!;
                                });
                              },
                              activeColor: const Color(0xFF5E35B1),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('รูปภาพ'),
                              value: 'image',
                              groupValue: _contentType,
                              onChanged: (value) {
                                setState(() {
                                  _contentType = value!;
                                });
                              },
                              activeColor: const Color(0xFF5E35B1),
                            ),
                          ),
                        ],
                      ),
                      RadioListTile<String>(
                        title: const Text('Google Content (รูป + เนื้อหา)'),
                        value: 'google',
                        groupValue: _contentType,
                        onChanged: (value) {
                          setState(() {
                            _contentType = value!;
                          });
                        },
                        activeColor: const Color(0xFF5E35B1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // YouTube URL Field (only for YouTube type)
                if (_contentType == 'youtube')
                  _buildTextField(
                    controller: _youtubeIdController,
                    label: 'YouTube URL',
                    hint: 'เช่น https://www.youtube.com/watch?v=dvhNOKRrOjk',
                    icon: Icons.video_library,
                  ),
                if (_contentType == 'youtube') const SizedBox(height: 20),

                // Thumbnail Path Field (for image and google types)
                if (_contentType == 'image' || _contentType == 'google')
                  Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Picker Button
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(
                                  0xFF5E35B1,
                                ).withValues(alpha: 0.3),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF5E35B1,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate,
                                    color: Color(0xFF5E35B1),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedImageName != null
                                            ? 'เลือกรูปภาพแล้ว'
                                            : '\u0e04\u0e25\u0e34\u0e01\u0e40\u0e1e\u0e37\u0e48\u0e2d\u0e40\u0e25\u0e37\u0e2d\u0e01\u0e23\u0e39\u0e1b\u0e20\u0e32\u0e1e',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: _selectedImageName != null
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _selectedImageName != null
                                              ? Colors.green
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      if (_selectedImageName != null)
                                        Text(
                                          _selectedImageName!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      else if (_thumbnailPathController
                                          .text
                                          .isNotEmpty)
                                        Text(
                                          'รูปเดิม: ${_thumbnailPathController.text.split('/').last}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF5E35B1),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Image Preview
                        if (_selectedImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '\u0e15\u0e31\u0e27\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e23\u0e39\u0e1b\u0e20\u0e32\u0e1e',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5E35B1),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    _selectedImageBytes!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                if (_contentType == 'image' || _contentType == 'google')
                  const SizedBox(height: 20),

                // Full Content Field (only for Google type)
                if (_contentType == 'google')
                  _buildTextField(
                    controller: _fullContentController,
                    label: 'เนื้อหาแบบเต็ม',
                    hint: 'ใส่เนื้อหาแบบยาวที่ต้องการแสดง',
                    icon: Icons.article,
                    maxLines: 10,
                  ),
                if (_contentType == 'google') const SizedBox(height: 10),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'เลือกประเภทเนื้อหา: YouTube (วิดีโอ), รูปภาพ (รูปเดี่ยว), หรือ Google Content (รูป + เนื้อหายาว)',
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
                    onPressed: _isUploading
                        ? null
                        : _saveExercise, // Disable button while uploading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: _isUploading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('กำลังบันทึก...'),
                            ],
                          )
                        : Text(
                            isEditing
                                ? 'บันทึกการแก้ไข'
                                : 'เพิ่ม Exercise Card',
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
            color: Colors.black.withValues(alpha: 0.05),
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
