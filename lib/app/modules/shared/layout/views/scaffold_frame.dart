import 'package:flutter/material.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import '../../widgets/_display_widgets/app_icon.dart';

/// Enhanced reusable scaffold layout with SliverAppBar and CustomScrollView
///
/// **Two variants:**
/// 1. Main pages (Home, Explore, Profile, Articles) - floating header with background image
/// 2. Detail pages (Place Detail, Achievement, etc) - pinned with solid background
///
/// ## Main Page Usage:
/// ```dart
/// ScaffoldFrame(
///   controller: controller,
///   headerContent: SearchBarWidget(...),
///   headerHeight: 75,
///   slivers: [
///     SliverList(...),
///   ],
/// )
/// ```
///
/// ## Detail Page Usage:
/// ```dart
/// ScaffoldFrame.detail(
///   title: 'Place Name',
///   actions: [
///     IconButton(icon: Icon(Icons.bookmark), onPressed: ...),
///     IconButton(icon: Icon(Icons.share), onPressed: ...),
///   ],
///   onRefresh: () => controller.refreshData(),
///   slivers: [
///     SliverToBoxAdapter(child: ...),
///   ],
/// )
/// ```
class ScaffoldFrame extends StatelessWidget {
  // Common properties
  final List<Widget> slivers;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  
  // Main page properties
  final Widget? headerContent;
  final double headerHeight;
  final dynamic controller;
  
  // Detail page properties
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Future<void> Function()? onRefresh;
  
  // Internal flags
  final bool _isDetailPage;
  
  // Styling
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;

  /// Constructor for main pages (Home, Explore, Profile, Articles)
  /// 
  /// Features:
  /// - Floating header with custom content
  /// - Background image from AppAssets.images.background
  /// - Pull to refresh via controller.refreshData()
  /// - Snap behavior on scroll
  const ScaffoldFrame({
    super.key,
    this.headerContent,
    this.headerHeight = 90,
    required this.slivers,
    required this.controller,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.appBarBackgroundColor,
  })  : title = null,
        actions = null,
        showBackButton = false,
        onRefresh = null,
        _isDetailPage = false;

  /// Constructor for detail pages (Place Detail, Post Detail, etc)
  /// 
  /// Features:
  /// - Pinned AppBar with title and actions
  /// - Solid background color (AppColors.background)
  /// - Pull to refresh via onRefresh callback
  const ScaffoldFrame.detail({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = true,
    required this.slivers,
    this.onRefresh,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.appBarBackgroundColor,
  })  : headerContent = null,
        headerHeight = 0,
        controller = null,
        _isDetailPage = true;

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        ...slivers,
      ],
    );

    // Determine refresh callback
    final refreshCallback = _getRefreshCallback();

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      body: refreshCallback != null
          ? RefreshIndicator(
              onRefresh: refreshCallback,
              child: scrollView,
            )
          : scrollView,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation:
          floatingActionButtonLocation ?? FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    if (_isDetailPage) {
      // Detail page: pinned AppBar with solid background (no image)
      return SliverAppBar(
        pinned: true,
        floating: false,
        snap: false,
        backgroundColor: appBarBackgroundColor ?? AppColors.backgroundContainer,
        elevation: 2,
        shadowColor: AppColors.shadowDark,
        leading: showBackButton
            ? Container(
                margin: const EdgeInsets.all(8),
                child: IconButton(
                  icon: AppIcon(AppAssets.icons.back, color: AppColors.primary, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            : null,
        title: title != null
            ? Text(
                title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              )
            : null,
        actions: actions != null
            ? [
                ...actions!,
                const SizedBox(width: 8),
              ]
            : null,
      );
    } else {
      // Main page: floating AppBar with background image
      return SliverAppBar(
        expandedHeight: headerContent != null ? headerHeight : 0,
        floating: true,
        snap: true,
        pinned: false,
        backgroundColor: appBarBackgroundColor ?? AppColors.primary,
        flexibleSpace: headerContent != null
            ? FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    Image.asset(
                      AppAssets.images.background,
                      fit: BoxFit.cover,
                    ),
                    // Header content on top
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 36, 16, 8),
                      child: headerContent,
                    ),
                  ],
                ),
                collapseMode: CollapseMode.parallax,
              )
            : null,
      );
    }
  }

  Future<void> Function()? _getRefreshCallback() {
    // Priority 1: Explicit onRefresh callback (for detail pages)
    if (onRefresh != null) {
      return onRefresh;
    }

    // Priority 2: Controller's refreshData method (for main pages)
    if (controller != null) {
      try {
        final dynamic refreshMethod = controller.refreshData;
        if (refreshMethod is Function) {
          return () async {
            await refreshMethod();
          };
        }
      } catch (e) {
        // Controller doesn't have refreshData method
        return null;
      }
    }

    return null;
  }
}
