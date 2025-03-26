import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/public_data_network/food_controller.dart';


class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodController()..fetchFoodData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("부산 맛집 리스트"),
        ),
        body: Consumer<FoodController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.items.isEmpty) {
              return const Center(child: Text("데이터가 없습니다."));
            }

            return ListView.builder(
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: item.image != null
                        ? Image.network(
                      item.image!,
                      width: 80,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.image_not_supported),
                    title: Text(item.mainTitle ?? ""),
                    subtitle: Text(item.title ?? ""),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
