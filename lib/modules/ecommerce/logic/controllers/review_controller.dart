import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/review_storage_service.dart';

class ReviewController extends ChangeNotifier {
  static final ReviewController instance = ReviewController._();
  ReviewController._() {
    loadFromStorage();
  }
  factory ReviewController() => instance;

  final ReviewStorageService _storageService = ReviewStorageService();
  final List<ReviewModel> _reviews = [];
  bool _isLoaded = false;

  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  bool get isLoaded => _isLoaded;

  Future<void> loadFromStorage() async {
    final loaded = await _storageService.loadReviews();
    _reviews.clear();
    _reviews.addAll(loaded);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addReview(ReviewModel review) async {
    _reviews.insert(0, review);
    notifyListeners();
    await _storageService.saveReviews(_reviews);
  }

  List<ReviewModel> getReviewsForProduct(String productName) {
    return _reviews
        .where((r) =>
            r.productName.toLowerCase().trim() ==
            productName.toLowerCase().trim())
        .toList();
  }

  double getAverageRating(String productName) {
    final productReviews = getReviewsForProduct(productName);
    if (productReviews.isEmpty) return 0.0;
    final total = productReviews.fold<int>(0, (sum, r) => sum + r.rating);
    return double.parse((total / productReviews.length).toStringAsFixed(1));
  }

  int getReviewCount(String productName) {
    return getReviewsForProduct(productName).length;
  }

  bool hasReviewForOrder(String orderId) {
    return _reviews.any((r) => r.orderId == orderId);
  }

  ReviewModel? getReviewForOrder(String orderId) {
    for (final r in _reviews) {
      if (r.orderId == orderId) return r;
    }
    return null;
  }
}

final ReviewController reviewController = ReviewController.instance;
