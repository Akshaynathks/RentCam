import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/features/home/widget/categories_card.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'All Categories',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading categories'));
          }

          final categories = snapshot.data?.docs ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text('No categories available'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.80,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final data = categories[index].data() as Map<String, dynamic>;
              return CategoryCard(
                imagePath: data['imageUrl'] ?? '',
                title: data['title'] ?? 'Unknown',
                onTap: () {
                  Navigator.pushNamed(context, '/products',
                      arguments: {'category': data['title']});
                },
              );
            },
          );
        },
      ),
    );
  }
}
