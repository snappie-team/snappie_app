import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/font_size.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../data/models/articles_model.dart';
import '../_display_widgets/network_image_widget.dart';

/// Horizontal article carousel for Home feed.
///
/// Displays a "Artikel" header and a horizontally-scrolling list of
/// article cards, each showing an image and a title. Tapping a card
/// opens the article URL in an external browser.
///
/// Usage:
/// ```dart
/// ArticleCarouselWidget(articles: controller.articles)
/// ```
class ArticleCarouselWidget extends StatelessWidget {
  final List<ArticlesModel> articles;

  const ArticleCarouselWidget({
    super.key,
    required this.articles,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.backgroundContainer,
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Section Header ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Artikel',
              style: TextStyle(
                fontSize: FontSize.getSize(FontSizeOption.medium),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ─── Horizontal Carousel ────────────────────────
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: articles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _ArticleCarouselCard(article: articles[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Individual carousel card
// ─────────────────────────────────────────────────────────────

class _ArticleCarouselCard extends StatelessWidget {
  final ArticlesModel article;

  const _ArticleCarouselCard({required this.article});

  static const double _cardWidth = 180;
  static const double _imageHeight = 130;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: _cardWidth,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image ──────────────────────────────────
            NetworkImageWidget(
              imageUrl: article.imageUrl ?? '',
              width: _cardWidth,
              height: _imageHeight,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(4),
              errorWidget: Container(
                width: _cardWidth,
                height: _imageHeight,
                color: AppColors.surfaceContainer,
                child: Icon(
                  Icons.article_outlined,
                  color: AppColors.textTertiary,
                  size: 32,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ─── Title ──────────────────────────────────
            Expanded(
              child: Text(
                article.title ?? 'Tanpa Judul',
                style: TextStyle(
                  fontSize: FontSize.getSize(FontSizeOption.small),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTap() async {
    final url = article.link;
    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        Logger.error('Error opening article URL', e, null, 'ArticleCarousel');
      }
    }
  }
}
