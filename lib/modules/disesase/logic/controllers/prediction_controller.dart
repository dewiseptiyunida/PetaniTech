import 'dart:io';
import '../services/api_service.dart';
import '../models/prediction_model.dart';

/// Controller untuk melakukan prediksi penyakit dari gambar.
class PredictionController {
  static const int _defaultMaxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  final ApiService _apiService;
  final int _maxFileSizeBytes;

  /// [apiService] dapat di-injeksi untuk test. [maxFileSizeBytes] opsional.
  PredictionController({ApiService? apiService, int? maxFileSizeBytes})
    : _apiService = apiService ?? ApiService(),
      _maxFileSizeBytes = maxFileSizeBytes ?? _defaultMaxFileSizeBytes;

  /// Melakukan prediksi dari [imageFile].
  Future<PredictionResult?> predict(File imageFile) async {
    try {
      if (!await _isFileUsable(imageFile)) return null;
      return await _apiService.predictImage(imageFile);
    } catch (_) {
      /// Return null jika file tidak valid atau terjadi error.
      return null;
    }
  }

  Future<bool> _isFileUsable(File file) async {
    if (!await file.exists()) return false;
    final size = await file.length();
    if (size == 0) return false;
    if (size > _maxFileSizeBytes) return false;
    return true;
  }
}
