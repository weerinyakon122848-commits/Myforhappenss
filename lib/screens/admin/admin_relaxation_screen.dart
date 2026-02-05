import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_data_provider.dart';
import '../../models/relaxation_activity.dart';

class AdminRelaxationScreen extends StatelessWidget {
  const AdminRelaxationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'จัดการกิจกรรมผ่อนคลาย',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          final activities = provider.relaxationActivities;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];

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
                  contentPadding: const EdgeInsets.all(20),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E35B1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.spa,
                      color: Color(0xFF5E35B1),
                      size: 30,
                    ),
                  ),
                  title: Text(
                    activity.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        activity.nameEn,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        activity.description,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Order: ${activity.order}',
                          style: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditDialog(context, provider, activity);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteDialog(context, provider, activity);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddDialog(context);
        },
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5E35B1),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มกิจกรรม'),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final nameEnController = TextEditingController();
    final descController = TextEditingController();
    final orderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มกิจกรรมผ่อนคลาย'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'ID',
                  hintText: 'เช่น aches, yoga',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ (ไทย)',
                  hintText: 'เช่น ปวดเมื่อย',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameEnController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ (English)',
                  hintText: 'เช่น Aches and Pains',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'คำอธิบาย',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: orderController,
                decoration: const InputDecoration(
                  labelText: 'ลำดับ',
                  hintText: 'เช่น 1, 2, 3',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              if (idController.text.isNotEmpty &&
                  nameController.text.isNotEmpty &&
                  nameEnController.text.isNotEmpty &&
                  descController.text.isNotEmpty &&
                  orderController.text.isNotEmpty) {
                final provider = Provider.of<AppDataProvider>(
                  context,
                  listen: false,
                );
                final newActivity = RelaxationActivity(
                  id: idController.text.trim(),
                  name: nameController.text.trim(),
                  nameEn: nameEnController.text.trim(),
                  description: descController.text.trim(),
                  icon: 'spa',
                  order: int.tryParse(orderController.text) ?? 0,
                );
                provider.addRelaxationActivity(newActivity);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('เพิ่มสำเร็จ')));
              }
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    AppDataProvider provider,
    RelaxationActivity activity,
  ) {
    final nameController = TextEditingController(text: activity.name);
    final nameEnController = TextEditingController(text: activity.nameEn);
    final descController = TextEditingController(text: activity.description);
    final orderController = TextEditingController(
      text: activity.order.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขกิจกรรม'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ (ไทย)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameEnController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ (English)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'คำอธิบาย',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: orderController,
                decoration: const InputDecoration(
                  labelText: 'ลำดับ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  nameEnController.text.isNotEmpty &&
                  descController.text.isNotEmpty &&
                  orderController.text.isNotEmpty) {
                final updated = RelaxationActivity(
                  id: activity.id,
                  name: nameController.text.trim(),
                  nameEn: nameEnController.text.trim(),
                  description: descController.text.trim(),
                  icon: activity.icon,
                  order: int.tryParse(orderController.text) ?? activity.order,
                );
                provider.updateRelaxationActivity(updated);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('แก้ไขสำเร็จ')));
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AppDataProvider provider,
    RelaxationActivity activity,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบกิจกรรม'),
        content: Text('คุณต้องการลบ "${activity.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteRelaxationActivity(activity.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('ลบสำเร็จ')));
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
