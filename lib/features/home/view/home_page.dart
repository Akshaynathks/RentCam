import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/features/home/model/offer_model.dart';
import 'package:rent_cam/features/home/model/product_model.dart';
import 'package:rent_cam/features/home/view/search.dart';
import 'package:rent_cam/features/home/widget/brand_card.dart';
import 'package:rent_cam/features/home/widget/carousel.dart';
import 'package:rent_cam/features/home/widget/categories_card.dart';
import 'package:rent_cam/features/home/widget/container_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      appBar: CustomAppBar(
        leftIcon: Lottie.asset(
          'assets/images/Animation - search.json',
          width: 60,
          height: 60,
          repeat: true,
        ),
        onLeftIconPressed: () async {
          final snapshot =
              await FirebaseFirestore.instance.collection('products').get();
          final allProducts = snapshot.docs
              .map((doc) => Product.fromMap(doc.data(), doc.id))
              .toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(allProducts: allProducts),
            ),
          );
        },
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/menu');
              },
              child: Lottie.asset(
                'assets/images/Animation - menu.json',
                width: 60,
                height: 60,
                repeat: true,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Lottie.asset(
            'assets/images/Animation - background.json',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('offers')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading offers'));
                    }

                    final offers = snapshot.data?.docs ?? [];
                    if (offers.isEmpty) {
                      return const Center(child: Text('No offers available'));
                    }

                    final offerList = offers.map((doc) {
                      final data = doc.data() as Map<String, dynamic>?;
                      return Offer(
                        id: doc.id,
                        imageUrl: data?['imageUrl'] ?? '',
                        couponCode: data?['couponCode'] ?? 'N/A',
                        percentage: data?['percentage'], description: '',
                      );
                    }).toList();

                    return CustomCarousel(
                      offers: offerList,
                      imagePaths: const [],
                    );
                  },
                ),
                const SizedBox(height: 10),
                buildSection(
                  title: 'Categories',
                  stream: FirebaseFirestore.instance
                      .collection('categories')
                      .snapshots(),
                  itemBuilder: (data) => CategoryCard(
                    imagePath: data['imageUrl'] ?? '',
                    title: data['title'] ?? 'Unknown',
                    onTap: () {
                      Navigator.pushNamed(context, '/products',
                          arguments: {'category': data['title']});
                    },
                  ),
                  height: 200, // Adjusted height for horizontal layout
                  isHorizontal: true, // Changed to horizontal
                  context: context,
                  routeName: '/all-categories',
                  itemWidth: 120, // Match your category card width
                ),
                const SizedBox(height: 10),
                buildSection(
                  title: 'Brands',
                  stream: FirebaseFirestore.instance
                      .collection('brands')
                      .snapshots(),
                  itemBuilder: (data) => BrandCard(
                    imagePath: data['imageUrl'] ?? '',
                    name: data['name'] ?? 'Unknown',
                    onTap: () {
                      Navigator.pushNamed(context, '/products',
                          arguments: {'brand': data['name']});
                    },
                  ),
                  height: 190,
                  isHorizontal: true,
                  context: context,
                  routeName: '/all-brands',
                  itemWidth: 100, // Match your brand card width
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
