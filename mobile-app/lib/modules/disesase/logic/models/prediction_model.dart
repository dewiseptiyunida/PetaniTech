import 'dart:ui' show Color;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart' show Colors;

/// Model untuk satu prediksi teratas.
class TopPrediction {
  final String className;
  final double confidence; // Dalam persen (0 - 100)
  final int rank;

  const TopPrediction({
    required this.className,
    required this.confidence,
    required this.rank,
  });

  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      className: (json['class_name'] ?? json['className'] ?? '').toString(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      rank: (json['rank'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'class_name': className,
    'confidence': confidence,
    'rank': rank,
  };

  // Helper
  bool get isHealthy {
    final lower = className.toLowerCase();
    return lower.contains('sehat') ||
        lower.contains('harvest') ||
        lower.contains('normal');
  }

  String get confidenceLevel {
    if (confidence >= PredictionResult.highThreshold) return 'Tinggi';
    if (confidence >= PredictionResult.mediumThreshold) return 'Sedang';
    return 'Rendah';
  }

  Color get confidenceColor {
    if (confidence >= PredictionResult.highThreshold) return Colors.green;
    if (confidence >= PredictionResult.mediumThreshold) return Colors.orange;
    return Colors.red;
  }

  String get diseaseCategory => isHealthy ? 'Sehat' : 'Penyakit';

  @override
  String toString() =>
      'TopPrediction(rank: $rank, class: $className, confidence: ${confidence.toStringAsFixed(1)}%)';
}

/// Hasil akhir prediksi (utama + top-N).
class PredictionResult {
  // Threshold konstanta
  static const double highThreshold = 80;
  static const double mediumThreshold = 60;
  static const double reliabilityHigh = 30;
  static const double reliabilityMedium = 15;
  static const double reliabilityLow = 5;

  final String predictedClass;
  final double confidencePercentage; // Dalam persen (0 - 100)
  final String? expertAdvice;
  final double? processingTime;
  final bool success;

  // Integrasi database
  final String? predictionId;
  final bool? savedToDatabase;
  final String? databaseNote;
  final Map<String, dynamic>? performance;

  // Prediksi tambahan
  final List<TopPrediction>? topPredictions;
  final Map<String, dynamic>? rawPredictions;

  const PredictionResult({
    required this.predictedClass,
    required this.confidencePercentage,
    required this.success,
    this.expertAdvice,
    this.processingTime,
    this.predictionId,
    this.savedToDatabase,
    this.databaseNote,
    this.performance,
    this.topPredictions,
    this.rawPredictions,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    List<TopPrediction>? parsedTop = _parseTopPredictions(json);
    parsedTop ??= _deriveTopFromRaw(json['raw_predictions']);

    return PredictionResult(
      predictedClass: (json['predicted_class'] ?? '').toString(),
      confidencePercentage: (json['confidence_percentage'] ?? 0).toDouble(),
      expertAdvice: json['expert_advice']?.toString(),
      processingTime:
          (json['processing_time'] is num)
              ? (json['processing_time'] as num).toDouble()
              : null,
      success: json['success'] == true,
      predictionId: json['prediction_id']?.toString(),
      savedToDatabase: json['saved_to_database'] as bool?,
      databaseNote: json['database_note']?.toString(),
      performance:
          json['performance'] is Map<String, dynamic>
              ? json['performance'] as Map<String, dynamic>
              : null,
      topPredictions: parsedTop,
      rawPredictions:
          json['raw_predictions'] is Map<String, dynamic>
              ? json['raw_predictions'] as Map<String, dynamic>
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'predicted_class': predictedClass,
    'confidence_percentage': confidencePercentage,
    'expert_advice': expertAdvice,
    'processing_time': processingTime,
    'success': success,
    'prediction_id': predictionId,
    'saved_to_database': savedToDatabase,
    'database_note': databaseNote,
    'performance': performance,
    'top_predictions': topPredictions?.map((p) => p.toJson()).toList(),
    'raw_predictions': rawPredictions,
  };

  // Parsing helpers
  static List<TopPrediction>? _parseTopPredictions(Map<String, dynamic> json) {
    final raw = json['top_predictions'];
    if (raw is! List) return null;

    try {
      final list =
          raw.asMap().entries.map((e) {
            final value = e.value;
            if (value is Map<String, dynamic>) {
              final map = Map<String, dynamic>.from(value);
              map.putIfAbsent('rank', () => e.key + 1);
              return TopPrediction.fromJson(map);
            }
            return TopPrediction(
              className: value.toString(),
              confidence: 0,
              rank: e.key + 1,
            );
          }).toList();
      _debugLog('Parsed top_predictions: ${list.length}');
      return list;
    } catch (e) {
      _debugLog('Failed parse top_predictions: $e');
      return null;
    }
  }

  static List<TopPrediction>? _deriveTopFromRaw(dynamic raw) {
    if (raw is! Map) return null;
    try {
      final entries =
          raw.entries
              .where((e) => e.value is num)
              .map<MapEntry<String, double>>(
                (e) => MapEntry(e.key.toString(), (e.value as num).toDouble()),
              )
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      final list =
          entries
              .take(3)
              .toList()
              .asMap()
              .entries
              .map(
                (e) => TopPrediction(
                  className: e.value.key,
                  confidence: e.value.value * 100,
                  rank: e.key + 1,
                ),
              )
              .toList();
      _debugLog('Derived top predictions from raw: ${list.length}');
      return list;
    } catch (e) {
      _debugLog('Failed derive from raw_predictions: $e');
      return null;
    }
  }

  // Helper utama
  bool get isHealthy {
    final lower = predictedClass.toLowerCase();
    return lower.contains('sehat') ||
        lower.contains('harvest') ||
        lower.contains('normal');
  }

  String get confidenceLevel {
    if (confidencePercentage >= highThreshold) return 'Tinggi';
    if (confidencePercentage >= mediumThreshold) return 'Sedang';
    return 'Rendah';
  }

  Color get confidenceColor {
    if (confidencePercentage >= highThreshold) return Colors.green;
    if (confidencePercentage >= mediumThreshold) return Colors.orange;
    return Colors.red;
  }

  String get diseaseCategory => isHealthy ? 'Sehat' : 'Penyakit';

  bool get hasTopPredictions =>
      topPredictions != null && topPredictions!.isNotEmpty;

  TopPrediction? get topPrediction =>
      hasTopPredictions ? topPredictions!.first : null;

  List<TopPrediction> get top3Predictions =>
      hasTopPredictions ? topPredictions!.take(3).toList() : const [];

  List<TopPrediction> get alternativePredictions {
    if (!hasTopPredictions) return const [];
    return topPredictions!
        .where((p) => p.className != predictedClass)
        .take(2)
        .toList();
  }

  // Diversity = selisih confidence prediksi 1 dan 2
  double get predictionDiversity {
    if (!hasTopPredictions || topPredictions!.length < 2) return 0;
    final top = topPredictions!.first.confidence;
    final second = topPredictions![1].confidence;
    return top - second;
  }

  String get reliabilityLevel {
    final d = predictionDiversity;
    if (!hasTopPredictions) return 'Unknown';
    if (d >= reliabilityHigh) return 'Sangat Yakin';
    if (d >= reliabilityMedium) return 'Yakin';
    if (d >= reliabilityLow) return 'Cukup Yakin';
    return 'Kurang Yakin';
  }

  Color get reliabilityColor {
    final d = predictionDiversity;
    if (d >= reliabilityHigh) return Colors.green;
    if (d >= reliabilityMedium) return Colors.lightGreen;
    if (d >= reliabilityLow) return Colors.orange;
    return Colors.red;
  }

  String get predictionSummary {
    if (!hasTopPredictions) {
      return '$predictedClass (${confidencePercentage.toStringAsFixed(1)}%)';
    }
    final summary = top3Predictions
        .map((p) => '${p.className} (${p.confidence.toStringAsFixed(1)}%)')
        .join(', ');
    return 'Top 3: $summary';
  }

  @override
  String toString() =>
      'PredictionResult(predictedClass: $predictedClass, confidence: ${confidencePercentage.toStringAsFixed(1)}%, topPredictions: ${topPredictions?.length ?? 0}, reliability: $reliabilityLevel, success: $success)';

  PredictionResult copyWith({
    String? predictedClass,
    double? confidencePercentage,
    String? expertAdvice,
    double? processingTime,
    bool? success,
    String? predictionId,
    bool? savedToDatabase,
    String? databaseNote,
    Map<String, dynamic>? performance,
    List<TopPrediction>? topPredictions,
    Map<String, dynamic>? rawPredictions,
  }) {
    return PredictionResult(
      predictedClass: predictedClass ?? this.predictedClass,
      confidencePercentage: confidencePercentage ?? this.confidencePercentage,
      expertAdvice: expertAdvice ?? this.expertAdvice,
      processingTime: processingTime ?? this.processingTime,
      success: success ?? this.success,
      predictionId: predictionId ?? this.predictionId,
      savedToDatabase: savedToDatabase ?? this.savedToDatabase,
      databaseNote: databaseNote ?? this.databaseNote,
      performance: performance ?? this.performance,
      topPredictions: topPredictions ?? this.topPredictions,
      rawPredictions: rawPredictions ?? this.rawPredictions,
    );
  }

  factory PredictionResult.fromRawPredictions({
    required Map<String, double> rawPredictions,
    String? expertAdvice,
    double? processingTime,
    String? predictionId,
  }) {
    final sorted =
        rawPredictions.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final main = sorted.first;

    final tops =
        sorted
            .take(3)
            .toList()
            .asMap()
            .entries
            .map(
              (e) => TopPrediction(
                className: e.value.key,
                confidence: e.value.value * 100,
                rank: e.key + 1,
              ),
            )
            .toList();

    return PredictionResult(
      predictedClass: main.key,
      confidencePercentage: main.value * 100,
      expertAdvice: expertAdvice,
      processingTime: processingTime,
      success: true,
      predictionId: predictionId,
      topPredictions: tops,
      rawPredictions: rawPredictions.map((k, v) => MapEntry(k, v as dynamic)),
    );
  }

  static void _debugLog(String msg) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[PredictionResult] $msg');
    }
  }
}

/// Extension untuk debugging manual.
extension PredictionResultDebug on PredictionResult {
  void debugPrint() {
    if (!kDebugMode) return;
    // ignore: avoid_print
    print(
      'Prediction: $predictedClass (${confidencePercentage.toStringAsFixed(1)}%), success=$success, reliability=$reliabilityLevel',
    );
    if (hasTopPredictions) {
      for (final p in top3Predictions) {
        // ignore: avoid_print
        print(
          '  #${p.rank} ${p.className} ${p.confidence.toStringAsFixed(1)}%',
        );
      }
      // ignore: avoid_print
      print('  Diversity: ${predictionDiversity.toStringAsFixed(1)}%');
    }
  }
}
