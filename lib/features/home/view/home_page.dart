import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/core/utils/responsive_helper.dart';
import 'package:rent_cam/features/offer/model/offer_model.dart';
import 'package:rent_cam/features/product/model/product_model.dart';
import 'package:rent_cam/features/search/view/search.dart';
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
        backgroundColorGradient: const [
          AppColors.cardGradientStart,
          AppColors.cardGradientEnd,
        ],
        leftIcon: Lottie.asset(
          'assets/images/Animation - search.json',
          width: ResponsiveHelper.getResponsiveIconSize(context, 60),
          height: ResponsiveHelper.getResponsiveIconSize(context, 60),
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
            padding: EdgeInsets.only(
              right: ResponsiveHelper.getResponsivePadding(context).right,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/menu');
              },
              child: Lottie.asset(
                'assets/images/Animation - menu.json',
                width: ResponsiveHelper.getResponsiveIconSize(context, 60),
                height: ResponsiveHelper.getResponsiveIconSize(context, 60),
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
                SizedBox(
                    height: ResponsiveHelper.getResponsiveHeight(context, 1)),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('offers')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading offers',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16),
                          ),
                        ),
                      );
                    }

                    final offers = snapshot.data?.docs ?? [];
                    if (offers.isEmpty) {
                      return Center(
                        child: Text(
                          'No offers available',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16),
                          ),
                        ),
                      );
                    }

                    final offerList = offers.map((doc) {
                      final data = doc.data() as Map<String, dynamic>?;
                      return Offer(
                        id: doc.id,
                        imageUrl: data?['imageUrl'] ?? '',
                        couponCode: data?['couponCode'] ?? 'N/A',
                        percentage: data?['percentage'],
                        description: '',
                      );
                    }).toList();

                    return CustomCarousel(
                      offers: offerList,
                      imagePaths: const [],
                    );
                  },
                ),
                SizedBox(
                    height: ResponsiveHelper.getResponsiveHeight(context, 1)),
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
                  height: ResponsiveHelper.isMobile(context) ? 200 : 250,
                  isHorizontal: true,
                  context: context,
                  routeName: '/all-categories',
                  itemWidth: ResponsiveHelper.isMobile(context) ? 120 : 150,
                ),
                SizedBox(
                    height: ResponsiveHelper.getResponsiveHeight(context, 1)),
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
                  height: ResponsiveHelper.isMobile(context) ? 190 : 240,
                  isHorizontal: true,
                  context: context,
                  routeName: '/all-brands',
                  itemWidth: ResponsiveHelper.isMobile(context) ? 100 : 130,
                ),
                SizedBox(
                    height: ResponsiveHelper.getResponsiveHeight(context, 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
