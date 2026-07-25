import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/promotion.dart';
import '../services/promotion_service.dart';

final promotionsProvider = FutureProvider.autoDispose<List<Promotion>>((ref) async {
  return await PromotionService.fetchActivePromotions();
});
