import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_data_provider.dart';
import '../../models/carousel_image.dart';

class AdminCarouselScreen extends StatelessWidget {
  const AdminCarouselScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'จัดการ Carousel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          final images = provider.carouselImages;

          if (images.isEmpty) {
            return const Center(
              child: Text(
                'ไม่มีรูปภาพ Carousel',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Preview
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.asset(
                        image.imagePath,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Info and Actions
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  image.imagePath,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: image.isActive
                                            ? Colors.green.withValues(alpha: 0.1)
                                            : Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        image.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: image.isActive
                                              ? Colors.green
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Order: ${image.order}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Toggle Active
                              IconButton(
                                icon: Icon(
                                  image.isActive
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: image.isActive
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  final updated = CarouselImage(
                                    id: image.id,
                                    imagePath: image.imagePath,
                                    order: image.order,
                                    isActive: !image.isActive,
                                  );
                                  provider.updateCarouselImage(updated);
                                },
                              ),
                              // Edit
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _showEditDialog(context, provider, image);
                                },
                              ),
                              // Delete
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _showDeleteDialog(context, provider, image);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
        label: const Text('เพิ่มรูปภาพ'),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final pathController = TextEditingController();
    final orderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มรูปภาพ Carousel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pathController,
              decoration: const InputDecoration(
                labelText: 'Image Path',
                hintText: 'เช่น assets/images/carousel1.png',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: orderController,
              decoration: const InputDecoration(
                labelText: 'Order (ลำดับ)',
                hintText: 'เช่น 1, 2, 3',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              if (pathController.text.isNotEmpty &&
                  orderController.text.isNotEmpty) {
                final provider = Provider.of<AppDataProvider>(
                  context,
                  listen: false,
                );
                final newImage = CarouselImage(
                  id: 'carousel_${DateTime.now().millisecondsSinceEpoch}',
                  imagePath: pathController.text.trim(),
                  order: int.tryParse(orderController.text) ?? 0,
                  isActive: true,
                );
                provider.addCarouselImage(newImage);
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
    CarouselImage image,
  ) {
    final pathController = TextEditingController(text: image.imagePath);
    final orderController = TextEditingController(text: image.order.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขรูปภาพ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pathController,
              decoration: const InputDecoration(
                labelText: 'Image Path',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: orderController,
              decoration: const InputDecoration(
                labelText: 'Order (ลำดับ)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              if (pathController.text.isNotEmpty &&
                  orderController.text.isNotEmpty) {
                final updated = CarouselImage(
                  id: image.id,
                  imagePath: pathController.text.trim(),
                  order: int.tryParse(orderController.text) ?? image.order,
                  isActive: image.isActive,
                );
                provider.updateCarouselImage(updated);
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
    CarouselImage image,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรูปภาพ'),
        content: const Text('คุณต้องการลบรูปภาพนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCarouselImage(image.id);
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
