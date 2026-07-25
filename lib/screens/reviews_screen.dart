import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/review_card.dart';
import '../theme/app_colors.dart';
import 'add_review_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class ReviewsScreen extends StatefulWidget {
  final String productId;

  const ReviewsScreen({super.key, required this.productId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoading = true);
    final fetched = await ReviewService.getProductReviews(widget.productId);
    if (mounted) {
      setState(() {
        _reviews = fetched;
        _isLoading = false;
      });
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    final sum = _reviews.fold(0.0, (prev, element) => prev + element.rating);
    return sum / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text(AppLocalizations.of(context)!.reviews),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24.0.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${_reviews.length} Reviews", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Row(
                          children: [
                            Text(_averageRating.toStringAsFixed(1), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8.w),
                            Row(children: List.generate(5, (index) => Icon(index < _averageRating ? Icons.star : Icons.star_half, color: AppColors.star, size: 20.sp))),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => AddReviewScreen(productId: widget.productId))
                        ).then((_) => _fetchReviews());
                      },
                      icon: Icon(Icons.edit, size: 16.sp),
                      label: Text(AppLocalizations.of(context)!.addReview),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        minimumSize: Size(120, 40),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _reviews.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.noReviewsYetBeTheFirstToReview))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          return ReviewCard(
                            review: _reviews[index],
                            onReviewChanged: _fetchReviews,
                          );
                        },
                      ),
              ),
            ],
          ),
    );
  }
}
