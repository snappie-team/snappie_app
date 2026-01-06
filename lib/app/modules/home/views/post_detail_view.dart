import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository_impl.dart';
import '../../shared/widgets/index.dart';
import '../../shared/widgets/_card_widgets/post_card.dart';

/// Post Detail View - Full screen view for a single post
/// Menerima postId dari arguments: {'postId': int}
class PostDetailView extends StatefulWidget {
  const PostDetailView({super.key});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final _postRepository = Get.find<PostRepository>();

  late int _postId;

  bool _isLoading = true;
  // bool _isLoadingComments = false;
  String _errorMessage = '';

  PostModel? _post;

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _postId = args?['postId'] ?? 0;

    if (_postId == 0) {
      setState(() {
        _errorMessage = 'Post ID tidak valid';
        _isLoading = false;
      });
    } else {
      _loadPost();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final post = await _postRepository.getPostById(_postId);

      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat post';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: _buildErrorState(),
      );
    }

    return ScaffoldFrame.detail(
      title: 'Postingan',
      onRefresh: _loadPost,
      slivers: [
        _isLoading
            ? const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            : SliverFillRemaining(
                hasScrollBody: false,
                child: PostCard(post: _post!),
              ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPost,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

}
