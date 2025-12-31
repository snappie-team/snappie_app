import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/articles_controller.dart';
import '../../shared/widgets/index.dart';

class ArticlesView extends GetView<ArticlesController> {
  const ArticlesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger lazy initialization saat view pertama kali di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeIfNeeded();
    });

    return ScaffoldFrame(
      controller: controller,
      headerHeight: 45,
      headerContent: SearchBarWidget(
        hintText: 'Cari artikel menarik...',
        enableGlassmorphism: true,
        margin: const EdgeInsets.only(top: 16),
        controller: controller.searchTextController,
        onChanged: (value) {
          controller.searchArticles(value);
        },
      ),
      slivers: [
        // Search result header
        Obx(() {
          if (controller.searchQuery.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: '${controller.articles.length} hasil',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(text: ' untuk "'),
                          TextSpan(
                            text: controller.searchQuery,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(text: '"'),
                        ],
                      ),
                    ),
                  ),
                  // Clear search button
                  InkWell(
                    onTap: () => controller.clearFilters(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hapus',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        
        // Articles List
        Obx(() {
          // Show loading state when initially loading or searching
          if (controller.isLoading && controller.articles.isEmpty) {
            return const LoadingStateWidget(isSliver: true);
          }
          
          // Show searching indicator
          if (controller.isSearching) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mencari...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (controller.articles.isEmpty) {
            // Show different empty state if searching
            if (controller.searchQuery.isNotEmpty) {
              return SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icon(Icons.search_off),
                  title: 'Tidak ada artikel yang cocok dengan "${controller.searchQuery}"',
                ),
              );
            }
            return SliverFillRemaining(
              child: NoDataEmptyState(),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= controller.articles.length) {
                    return const SizedBox.shrink();
                  }

                  final article = controller.articles[index];
                  return ArticleCardWidget(
                    article: article,
                  );
                },
                childCount: controller.articles.length,
              ),
            ),
          );
        }),
      ],
    );
  }
}
