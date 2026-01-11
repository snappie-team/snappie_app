import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';

/// Reusable scaffold layout with AppBar and content wrapper
///
/// Usage:
/// ```dart
/// DetailLayout(
///   title: 'Page Title',
///   body: YourWidget(),
///   isCard: true, // Optional: adds margin and card decoration
///   leading: CustomLeadingWidget(), // Optional: custom leading widget
/// )
/// ```
class DetailLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final bool useContainerWrapper;
  final EdgeInsets? bodyPadding;
  final bool isCard;
  final Widget? leading;

  const DetailLayout({
    super.key,
    required this.title,
    required this.body,
    this.onBackPressed,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.useContainerWrapper = true,
    this.bodyPadding,
    this.isCard = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: FontSize.getSize(FontSizeOption.medium),
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: appBarBackgroundColor ?? AppColors.background,
        surfaceTintColor: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.shadowDark,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primary,
          ),
          onPressed: () => Get.back(),
        ),
        actions: actions == null ? null : [
          ...actions!,
        ],
        titleSpacing: 0, // Remove default spacing between leading and title
      ),
      body: isCard ? _buildCardBody() : body,
    );
  }

  Widget _buildCardBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Container(
        decoration: BoxDecoration(
          // border: Border.all(color: AppColors.border),
          color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
        ),
        padding: bodyPadding ?? const EdgeInsets.all(24.0),
        child: body,
      ),
    );
  }
}
