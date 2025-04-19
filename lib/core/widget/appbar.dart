import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color backgroundColor;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? centerWidget;
  final double centerWidgetHeight;
  final double centerWidgetWidth;
  final Widget? leadingAction;
  final String? backButtonRoute; // New: Route to navigate when back is pressed
  final Widget? leftIcon; // New: Left icon/widget (like search animation)
  final VoidCallback? onLeftIconPressed; // New: Callback for left icon press
  final bool showTitle; // New: Control title visibility
  final double elevation; // New: AppBar elevation
  final Color? backButtonColor; // New: Custom back button color
  final Color? titleColor; // New: Custom title color
  final double titleFontSize; // New: Custom title font size

  const CustomAppBar({
    super.key,
    this.title,
    this.backgroundColor = AppColors.overlay,
    this.showBackButton = true,
    this.actions,
    this.centerWidget,
    this.centerWidgetHeight = 70,
    this.centerWidgetWidth = 70,
    this.leadingAction,
    this.backButtonRoute,
    this.leftIcon,
    this.onLeftIconPressed,
    this.showTitle = true,
    this.elevation = 0,
    this.backButtonColor = AppColors.buttonPrimary,
    this.titleColor = AppColors.textPrimary,
    this.titleFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: _buildLeading(context),
      title: _buildTitle(),
      actions: _buildActions(),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leadingAction != null) return leadingAction;
    if (leftIcon != null) {
      return IconButton(
        icon: leftIcon!,
        onPressed: onLeftIconPressed,
      );
    }
    if (showBackButton) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: backButtonColor),
        onPressed: () {
          if (backButtonRoute != null) {
            Navigator.pushNamed(context, backButtonRoute!);
          } else {
            Navigator.pop(context);
          }
        },
      );
    }
    return null;
  }

  Widget? _buildTitle() {
    if (centerWidget != null) {
      return SizedBox(
        height: centerWidgetHeight,
        width: centerWidgetWidth,
        child: centerWidget,
      );
    }
    if (title != null && showTitle) {
      return Text(
        title!,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.bold,
          fontSize: titleFontSize,
        ),
      );
    }
    return null;                     
  }

  List<Widget>? _buildActions() {
    if (actions != null && actions!.isNotEmpty) {
      return actions;
    }
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}