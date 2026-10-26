import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_model.dart';

class ReviewStorageService {
  static const String _storageKey = 'petanitech_product_reviews_v1';

  /// Memuat daftar ulasan dari SharedPreferences.
  /// Jika belum ada, sediakan beberapa ulasan awal (seed data) agar UI tidak kosong.
  Future<List<ReviewModel>> loadReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded
            .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Seed data awal untuk pengujian
      final seed = _getInitialSeedReviews();
      await saveReviews(seed);
      return seed;
    } catch (e) {
      debugPrint('Error loading reviews from storage: $e');
      return _getInitialSeedReviews();
    }
  }

  /// Menyimpan seluruh ulasan ke SharedPreferences.
  Future<void> saveReviews(List<ReviewModel> reviews) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString =
          jsonEncode(reviews.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving reviews to storage: $e');
    }
  }

  List<ReviewModel> _getInitialSeedReviews() {
    final now = DateTime.now();
    return [
      ReviewModel(
        id: 'REV-001',
        orderId: 'PT-HIST-01',
        productName: 'Pupuk NPK Mutiara',
        variant: '1 Kg',
        userName: 'Andi Saputra',
        rating: 5,
        courierRating: 5,
        comment:
            'Pupuk NPK original, butirannya biru cerah merata dan larut dengan baik. Tanaman cabai saya langsung subur setelah seminggu pemakaian.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ReviewModel(
        id: 'REV-002',
        orderId: 'PT-HIST-02',
        productName: 'Pupuk NPK Mutiara',
        variant: '5 Kg',
        userName: 'Siti Rahmawati',
        rating: 4,
        courierRating: 5,
        comment:
            'Pengemasan sangat rapi dengan bubble wrap tebal. Kurir ramah dan cepat sampai. Kualitas pupuk bagus.',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      ReviewModel(
        id: 'REV-003',
        orderId: 'PT-HIST-03',
        productName: 'Benih Padi Unggul',
        variant: 'Kemasan 1 Kg',
        userName: 'Pak Wahyu Tani',
        rating: 5,
        courierRating: 4,
        comment:
            'Daya kecambah benih sangat tinggi di atas 90%. Tidak ada gabah hampa. Sangat recommended untuk petani padi.',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      ReviewModel(
        id: 'REV-004',
        orderId: 'PT-HIST-04',
        productName: 'Cangkul Besi',
        userName: 'Hendra Wijaya',
        rating: 5,
        courierRating: 5,
        comment:
            'Besi tebal dan kuat, mata cangkul tajam langsung siap pakai untuk mengolah lahan keras. Gagang presisi.',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];
  }
}
