import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../models/review.dart';
import '../theme/app_colors.dart';
import '../services/session_service.dart';
import '../services/review_service.dart';
import '../screens/add_review_screen.dart';

class ReviewCard extends StatefulWidget {
  final Review review;
  final VoidCallback? onReviewChanged;

  const ReviewCard({super.key, required this.review, this.onReviewChanged});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionService.getUser();
    if (mounted) {
      setState(() {
        _currentUserName = user['name'];
      });
    }
  }

  void _editReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddReviewScreen(
          productId: widget.review.productId,
          existingReview: widget.review,
        ),
      ),
    ).then((_) {
      if (widget.onReviewChanged != null) {
        widget.onReviewChanged!();
      }
    });
  }

  Future<void> _deleteReview() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ReviewService.deleteReview(widget.review.id);
      if (success) {
        if (mounted && widget.onReviewChanged != null) {
          widget.onReviewChanged!();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete review')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _currentUserName != null && _currentUserName == widget.review.userName;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(widget.review.userAvatar),
                radius: 20,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.review.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.review.rating ? Icons.star : Icons.star_border,
                          color: AppColors.star,
                          size: 16.sp,
                        );
                      }),
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${widget.review.createdAt.day} ${_monthName(widget.review.createdAt.month)} ${widget.review.createdAt.year}",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                  ),
                  if (isOwner)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 16.sp, color: AppColors.tertiaryNormal),
                          onPressed: _editReview,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.all(4.w),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 16.sp, color: Colors.red),
                          onPressed: _deleteReview,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.all(4.w),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(widget.review.content, style: const TextStyle(color: AppColors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}
