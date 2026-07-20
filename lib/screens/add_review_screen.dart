import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class AddReviewScreen extends StatefulWidget {
  final String productId;
  final Review? existingReview;

  const AddReviewScreen({super.key, required this.productId, this.existingReview});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  double _rating = 0.0;
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _contentController.text = widget.existingReview!.content;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a rating.')));
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write a review.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      Review? result;
      if (widget.existingReview != null) {
        result = await ReviewService.updateReview(widget.existingReview!.id, _rating, _contentController.text.trim());
      } else {
        result = await ReviewService.createReview(widget.productId, _rating, _contentController.text.trim());
      }

      if (mounted) {
        if (result != null) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit review. You may have already reviewed this product.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred.')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(isEditing ? "Edit Review" : "Add Review"),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "How was your experience?",
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Text("Rating", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(width: 12.w),
                Text(
                  "${_rating.toInt()}/5",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = (index + 1).toDouble()),
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 36.sp,
                      color: AppColors.star,
                    ),
                  ),
                );
              }),
            ),
            const Spacer(),
            _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: isEditing ? "Save Changes" : "Submit Review",
                  onPressed: _submitReview,
                ),
          ],
        ),
      ),
    );
  }
}
