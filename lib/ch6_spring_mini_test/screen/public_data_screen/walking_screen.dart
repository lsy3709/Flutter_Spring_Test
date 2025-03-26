import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/public_data_network/walking_controller.dart';


class WalkingScreen extends StatelessWidget {
  const WalkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<WalkingController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('부산 도보 여행')),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: controller.items.length,
        itemBuilder: (context, index) {
          final item = controller.items[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: item.image != null
                  ? Image.network(item.image!, width: 60, height: 60, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported),
              title: Text(item.mainTitle ?? '제목 없음'),
              subtitle: Text(item.title ?? ''),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.fetchWalkingData(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
