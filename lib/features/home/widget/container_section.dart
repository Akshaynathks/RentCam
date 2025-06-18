import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/core/utils/responsive_helper.dart';

Widget buildSection({
  required String title,
  required Stream<QuerySnapshot> stream,
  required Widget Function(Map<String, dynamic> data) itemBuilder,
  required double height,
  bool isHorizontal = false,
  required BuildContext context,
  String routeName = '',
  double itemWidth = 120,
}) {
  return Container(
    height: height,
    padding: ResponsiveHelper.getResponsivePadding(context),
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
          padding: EdgeInsets.only(
            left: ResponsiveHelper.getResponsivePadding(context).left / 2,
            top: ResponsiveHelper.getResponsivePadding(context).top / 2,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.buttonText,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 0.5)),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading $title',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                  ),
                );
              }

              final items = snapshot.data?.docs ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'No $title available',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                  ),
                );
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
                          padding: EdgeInsets.only(
                            right:
                                ResponsiveHelper.getResponsivePadding(context)
                                        .right /
                                    2,
                          ),
                          child: itemBuilder(data),
                        ),
                      );
                    }).toList(),
                    // Add See More button
                    SizedBox(
                      width: itemWidth,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: ResponsiveHelper.getResponsivePadding(context)
                                  .right /
                              2,
                        ),
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
                                  height:
                                      ResponsiveHelper.getResponsiveIconSize(
                                          context, 60),
                                  width: ResponsiveHelper.getResponsiveIconSize(
                                      context, 60),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200],
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size:
                                        ResponsiveHelper.getResponsiveIconSize(
                                            context, 40),
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        ResponsiveHelper.getResponsiveHeight(
                                            context, 1)),
                                Text(
                                  'See More',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                            context, 14),
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      ResponsiveHelper.getResponsiveGridCrossAxisCount(context),
                  crossAxisSpacing:
                      ResponsiveHelper.getResponsivePadding(context).horizontal,
                  mainAxisSpacing:
                      ResponsiveHelper.getResponsivePadding(context).vertical,
                  childAspectRatio: 0.80,
                ),
                itemCount: limitedItems.length,
                itemBuilder: (context, index) {
                  final data =
                      limitedItems[index].data() as Map<String, dynamic>;
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
