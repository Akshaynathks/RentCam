import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Color>?
      backgroundColorGradient; 
  final Color? backgroundColor; 
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? centerWidget;
  final double centerWidgetHeight;
  final double centerWidgetWidth;
  final Widget? leadingAction;
  final String? backButtonRoute;
  final Widget? leftIcon;
  final VoidCallback? onLeftIconPressed;
  final bool showTitle;
  final double elevation;
  final Color? backButtonColor;
  final Color? titleColor;
  final double titleFontSize;

  const CustomAppBar({
    super.key,
    this.title,
    this.backgroundColorGradient,
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
      backgroundColor:
          Colors.transparent, 
      flexibleSpace: _buildBackground(), 
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: _buildLeading(context),
      title: _buildTitle(),
      actions: _buildActions(),
    );
  }

  Widget? _buildBackground() {
    if (backgroundColorGradient != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundColorGradient!,
            begin: Alignment.topLeft ,
            end: Alignment.bottomRight,
          ),
        ),
      );
    } else if (backgroundColor != null) {
      return Container(
        color: backgroundColor,
      );
    }
    return null;
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
