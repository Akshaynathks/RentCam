import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/features/home/widget/brand_card.dart';

class AllBrandsPage extends StatelessWidget {
  const AllBrandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'All Brands',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('brands').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading brands'));
          }

          final brands = snapshot.data?.docs ?? [];
          if (brands.isEmpty) {
            return const Center(child: Text('No brands available'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 4 items per row
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.75,
            ),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final data = brands[index].data() as Map<String, dynamic>;
              return BrandCard(
                imagePath: data['imageUrl'] ?? '',
                name: data['name'] ?? 'Unknown',
                onTap: () {
                  Navigator.pushNamed(context, '/products',
                      arguments: {'brand': data['name']});
                },
              );
            },
          );
        },
      ),
    );
  }
}
