import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';

Widget buildSection({
  required String title,
  required Stream<QuerySnapshot> stream,
  required Widget Function(Map<String, dynamic> data) itemBuilder,
  required double height,
  bool isHorizontal = false,
  required BuildContext context,
  String routeName = '',
  double itemWidth = 120, // Width for horizontal items
}) {
  return Container(
    height: height,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          AppColors.cardGradientEnd,
          AppColors.cardGradientStart,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.buttonText,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading $title'));
              }

              final items = snapshot.data?.docs ?? [];
              if (items.isEmpty) {
                return Center(child: Text('No $title available'));
              }

              // Take only first 4 items
              final limitedItems = items.take(4).toList();

              if (isHorizontal) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...limitedItems.map((item) {
                      final data = item.data() as Map<String, dynamic>;
                      return SizedBox(
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: itemBuilder(data),
                        ),
                      );
                    }).toList(),
                    // Add See More button
                    SizedBox(
                      width: itemWidth,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, routeName),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppColors.cardGradientStart,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'See More',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.buttonText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Grid view for non-horizontal sections
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.80,
                ),
                itemCount: limitedItems.length,
                itemBuilder: (context, index) {
                  final data = limitedItems[index].data() as Map<String, dynamic>;
                  return itemBuilder(data);
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}