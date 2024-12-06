import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; // Optional AppBar title
  final Color backgroundColor; // AppBar background color
  final bool showBackButton; // Whether to show back button
  final List<Widget>? actions; // Optional action buttons
  final Widget? centerWidget; // Optional widget in the center (e.g., photo)
  final double centerWidgetHeight; // Height for the center widget
  final double centerWidgetWidth; // Width for the center widget

  const CustomAppBar({
    super.key,
    this.title, // Title is optional
    this.backgroundColor = Colors.white, // Default color
    this.showBackButton = true, // Default to show back button
    this.actions,
    this.centerWidget, // Optional center widget
    this.centerWidgetHeight = 70, // Default height for center widget
    this.centerWidgetWidth = 70, // Default width for center widget
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor,
      centerTitle: true,
      automaticallyImplyLeading: false, // Disable default back button behavior
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context); // Default back action
              },
            )
          : null, // No back button if `showBackButton` is false
      title: centerWidget != null
          ? SizedBox(
              height: centerWidgetHeight, // Apply custom height
              width: centerWidgetWidth, // Apply custom width
              child: centerWidget, // Display center widget
            )
          : (title != null
              ? Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.black, // Title text color
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null), // Show title if no center widget is provided
      actions: actions, // Optional action buttons
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56); // Default AppBar height
}
