import 'dart:convert';
import 'dart:ui' show Color;
import 'package:flutter/material.dart' show Colors;

import 'prediction_model.dart';

/// Set ke true bila ingin melihat log parsing di debug console.
const bool _kEnableHistoryDebugLog = false;

/// Helper sederhana untuk logging terkontrol.
void _log(String msg) {
  if (_kEnableHistoryDebugLog) {
    // ignore: avoid_print
    print('[HistoryModel] $msg');
  }
}

/// Parsing aman untuk DateTime dari dynamic value.
DateTime _safeParseDate(dynamic value) {
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return DateTime.now();
    }
  }
  return DateTime.now();
}

/// Response utama riwayat prediksi.
class HistoryResponse {
  final bool success;
  final List<PredictionHistoryItem> history;
  final HistoryPagination pagination;

  HistoryResponse({
    required this.success,
    required this.history,
    required this.pagination,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    // Parse daftar history
    final rawHistory = json['history'];
    final historyItems =
        (rawHistory is List)
            ? rawHistory
                .whereType<Map<String, dynamic>>()
                .map(PredictionHistoryItem.fromJson)
                .toList()
            : <PredictionHistoryItem>[];

    // Parse pagination
    final rawPagination = json['pagination'];
    final pagination =
        (rawPagination is Map<String, dynamic>)
            ? HistoryPagination.fromJson(rawPagination)
            : HistoryPagination.empty();

    _log('Parsed ${historyItems.length} history items');

    return HistoryResponse(
      success: json['success'] == true,
      history: historyItems,
      pagination: pagination,
    );
  }
}

/// Item riwayat satu prediksi.
class PredictionHistoryItem {
  final String id;
  final String imageFilename;
  final String predictedClass;
  final double confidencePercentage;
  final String? expertAdvice;
  final DateTime createdAt;
  final double? processingTime;
  final List<ChatMessageItem> chatMessages;
  final List<TopPrediction>? topPredictions;

  PredictionHistoryItem({
    required this.id,
    required this.imageFilename,
    required this.predictedClass,
    required this.confidencePercentage,
    this.expertAdvice,
    required this.createdAt,
    this.processingTime,
    required this.chatMessages,
    this.topPredictions,
  });

  factory PredictionHistoryItem.fromJson(Map<String, dynamic> json) {
    // Parse chat_messages (bisa berupa List atau String JSON)
    final rawChat = json['chat_messages'];
    List<ChatMessageItem> messages = [];
    if (rawChat != null) {
      dynamic chatData = rawChat;
      if (chatData is String) {
        try {
          chatData = jsonDecode(chatData);
        } catch (_) {
          chatData = [];
        }
      }
      if (chatData is List) {
        messages =
            chatData
                .whereType<Map<String, dynamic>>()
                .map(ChatMessageItem.fromJson)
                .toList();
      }
    }

    // Parse top_predictions dan tambahkan rank bila belum ada
    List<TopPrediction>? topPredictions;
    final rawTop = json['top_predictions'];
    if (rawTop is List) {
      topPredictions =
          rawTop
              .asMap()
              .entries
              .map((entry) {
                final v = entry.value;
                if (v is Map<String, dynamic>) {
                  final mapCopy = Map<String, dynamic>.from(v);
                  mapCopy.putIfAbsent('rank', () => entry.key + 1);
                  return TopPrediction.fromJson(mapCopy);
                }
                return null;
              })
              .whereType<TopPrediction>()
              .toList();
    }

    return PredictionHistoryItem(
      id: json['id']?.toString() ?? '',
      imageFilename: json['image_filename']?.toString() ?? '',
      predictedClass: json['predicted_class']?.toString() ?? '',
      confidencePercentage:
          (json['confidence_percentage'] is num)
              ? (json['confidence_percentage'] as num).toDouble()
              : 0.0,
      expertAdvice: json['expert_advice']?.toString(),
      createdAt: _safeParseDate(json['created_at']),
      processingTime:
          (json['processing_time'] is num)
              ? (json['processing_time'] as num).toDouble()
              : null,
      chatMessages: messages,
      topPredictions: topPredictions,
    );
  }

  /// Mengelompokkan apakah hasil prediksi sehat atau sakit.
  String get diseaseCategory {
    final lc = predictedClass.toLowerCase();
    if (lc.contains('sehat') ||
        lc.contains('harvest') ||
        lc.contains('normal')) {
      return 'Sehat';
    }
    return 'Penyakit';
  }

  bool get isHealthy => diseaseCategory == 'Sehat';

  /// Warna indikasi tingkat confidence.
  Color get confidenceColor {
    if (confidencePercentage >= 80) return Colors.green;
    if (confidencePercentage >= 60) return Colors.orange;
    return Colors.red;
  }

  bool get hasTopPredictions =>
      topPredictions != null && topPredictions!.isNotEmpty;

  /// Ambil maksimal 3 teratas.
  List<TopPrediction> get top3Predictions =>
      hasTopPredictions ? topPredictions!.take(3).toList() : [];
}

/// Chat antara user dan sistem terkait satu riwayat.
class ChatMessageItem {
  final String id;
  final String message;
  final bool isUser;
  final DateTime createdAt;
  final String? responseSource;

  ChatMessageItem({
    required this.id,
    required this.message,
    required this.isUser,
    required this.createdAt,
    this.responseSource,
  });

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    return ChatMessageItem(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isUser: json['is_user'] == true,
      createdAt: _safeParseDate(json['created_at']),
      responseSource: json['response_source']?.toString(),
    );
  }
}

/// Informasi paginasi saat mengambil data history dari backend.
class HistoryPagination {
  final int limit;
  final int offset;
  final int total;
  final bool hasMore;

  HistoryPagination({
    required this.limit,
    required this.offset,
    required this.total,
    required this.hasMore,
  });

  factory HistoryPagination.fromJson(Map<String, dynamic> json) {
    return HistoryPagination(
      limit: (json['limit'] is int) ? json['limit'] as int : 20,
      offset: (json['offset'] is int) ? json['offset'] as int : 0,
      total: (json['total'] is int) ? json['total'] as int : 0,
      hasMore: json['has_more'] == true,
    );
  }

  factory HistoryPagination.empty() =>
      HistoryPagination(limit: 20, offset: 0, total: 0, hasMore: false);
}
