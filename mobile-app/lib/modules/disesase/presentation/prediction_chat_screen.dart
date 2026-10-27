// ignore_for_file: avoid_print

import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:petanitech_mobile/modules/disesase/logic/controllers/chat_controller.dart';
import 'package:petanitech_mobile/modules/disesase/logic/controllers/prediction_controller.dart';
import 'package:petanitech_mobile/modules/disesase/logic/models/history_model.dart';
import 'package:petanitech_mobile/modules/disesase/logic/models/prediction_model.dart';
import 'package:petanitech_mobile/modules/disesase/logic/services/api_service.dart';
import 'package:petanitech_mobile/modules/disesase/presentation/history_screen.dart';

class PredictionChatScreen extends StatefulWidget {
  final PredictionHistoryItem? historyItem;
  final bool isHistoryMode;

  const PredictionChatScreen({
    Key? key,
    this.historyItem,
    this.isHistoryMode = false,
  }) : super(key: key);

  @override
  State<PredictionChatScreen> createState() => _PredictionChatScreenState();
}

class _PredictionChatScreenState extends State<PredictionChatScreen>
    with TickerProviderStateMixin {
  // State utama gambar & hasil prediksi
  File? _selectedImage;
  PredictionResult? _predictionResult;

  // Controllers
  final predictionController = PredictionController();
  final chatController = ChatController();
  final picker = ImagePicker();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();

  // Chat state
  final List<Map<String, dynamic>> _messages = [];
  bool _isChatLoading = false;
  bool _isChatMinimized = true;
  bool _isChatFullScreen = false;

  // UI / Animations
  late AnimationController _chatAnimationController;
  late Animation<double> _chatAnimation;
  late DraggableScrollableController _draggableController;

  // Loading & server
  bool _isAnalyzing = false;
  bool _isServerReachable = true;
  String _serverStatus = "Memeriksa server...";

  // Cached future untuk gambar riwayat
  Future<String?>? _historyImageUrlFuture;

  // Theme colors
  final Color primaryColor = Colors.green.shade700;
  final Color accentColor = Colors.green.shade300;
  final Color userBubbleColor = Colors.green.shade600;
  final Color botBubbleColor = Colors.grey.shade100;
  final Color backgroundColor = Colors.grey.shade50;

  @override
  void initState() {
    super.initState();

    _chatAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _chatAnimation = CurvedAnimation(
      parent: _chatAnimationController,
      curve: Curves.easeInOut,
    );
    _draggableController = DraggableScrollableController();

    if (widget.isHistoryMode && widget.historyItem != null) {
      _loadHistoryData();
      _historyImageUrlFuture = _getImageUrl(widget.historyItem!.id);
    }

    _checkServerStatus();
  }

  /// Mengecek status server API sederhana.
  Future<void> _checkServerStatus() async {
    try {
      final isActive = await ApiService().checkServerStatus();
      if (mounted) {
        setState(() {
          _isServerReachable = isActive;
          _serverStatus = isActive ? "Server aktif" : "Server tidak aktif";
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isServerReachable = false;
          _serverStatus = "Server tidak aktif";
        });
      }
    }
  }

  /// Memuat data history (prediksi + chat + top predictions).
  void _loadHistoryData() {
    final history = widget.historyItem!;
    setState(() {
      _predictionResult = PredictionResult(
        predictedClass: history.predictedClass,
        confidencePercentage: history.confidencePercentage,
        expertAdvice: history.expertAdvice,
        success: true,
        predictionId: history.id,
        processingTime: history.processingTime,
        topPredictions: history.topPredictions,
      );

      _messages.clear();

      if (history.expertAdvice != null && history.expertAdvice!.isNotEmpty) {
        _messages.add({
          'isUser': false,
          'message': history.expertAdvice!,
          'timestamp': history.createdAt,
          'isExpertAdvice': true,
        });
      }

      final sorted = List<ChatMessageItem>.from(history.chatMessages)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final m in sorted) {
        _messages.add({
          'isUser': m.isUser,
          'message': m.message,
          'timestamp': m.createdAt,
          'isExpertAdvice': false,
        });
      }

      _isChatMinimized = true;
    });

    _scrollChatToBottom();
  }

  /// Memilih gambar dari kamera atau galeri.
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;
    setState(() {
      _selectedImage = File(pickedFile.path);
      _predictionResult = null;
      _messages.clear();
    });
  }

  /// Menganalisis gambar yang dipilih dengan model prediksi backend.
  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    await _checkServerStatus();
    if (!_isServerReachable) {
      _showServerOfflineDialog();
      return;
    }

    setState(() => _isAnalyzing = true);
    try {
      final result = await predictionController.predict(_selectedImage!);
      setState(() {
        _isAnalyzing = false;
        _predictionResult = result;
        _messages.clear();
        _isChatMinimized = true;

        if (result != null && result.expertAdvice != null) {
          _messages.add({
            'isUser': false,
            'message': result.expertAdvice!,
            'timestamp': DateTime.now(),
            'isExpertAdvice': true,
          });
        }
      });
      _scrollChatToBottom();
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showAnalyzeErrorDialog(e);
    }
  }

  /// Mengirim pesan chat ke AI terkait hasil prediksi.
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _predictionResult == null) return;

    final timestamp = DateTime.now();
    setState(() {
      _messages.add({
        'isUser': true,
        'message': text,
        'timestamp': timestamp,
        'isExpertAdvice': false,
      });
      _isChatLoading = true;
    });
    _messageController.clear();
    _scrollChatToBottom();

    final response = await chatController.sendMessage(
      text,
      _predictionResult!.predictedClass,
    );

    setState(() {
      _messages.add({
        'isUser': false,
        'message':
            response?.answer ??
            'Maaf, terjadi kesalahan saat memproses pertanyaan Anda',
        'timestamp': DateTime.now(),
        'isExpertAdvice': false,
      });
      _isChatLoading = false;
    });
    _scrollChatToBottom();
  }

  /// Toggle ukuran panel chat (minimize/expand/full).
  void _toggleChat() {
    setState(() {
      if (_isChatMinimized) {
        _isChatMinimized = false;
        _isChatFullScreen = false;
      } else if (!_isChatFullScreen) {
        _isChatMinimized = true;
        _isChatFullScreen = false;
      } else {
        _isChatMinimized = true;
        _isChatFullScreen = false;
      }
    });

    if (_isChatMinimized) {
      _chatAnimationController.reverse();
    } else {
      _chatAnimationController.forward();
    }
  }

  /// Toggle mode full-screen chat.
  void _toggleFullScreen() {
    setState(() {
      _isChatFullScreen = !_isChatFullScreen;
      if (_isChatFullScreen) _isChatMinimized = false;
    });
    if (!_isChatMinimized) {
      _chatAnimationController.forward();
    }
  }

  /// Scroll chat ke bawah (pesan terbaru).
  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Format timestamp relatif.
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('dd/MM HH:mm').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  void dispose() {
    _chatScrollController.dispose();
    _mainScrollController.dispose();
    _messageController.dispose();
    _chatAnimationController.dispose();
    _draggableController.dispose();
    super.dispose();
  }

  /// Memformat teks expert advice menjadi blok kaya.
  Widget _buildFormattedExpertAdvice(String advice) {
    final List<Widget> widgets = [];
    final lines = advice.split('\n');

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      Widget textWidget;
      final trimmed = line.trim();

      if (RegExp(r'^[🦠🏠💡👁️⚠️🔧💊🛡️🌾🚨].*:$').hasMatch(trimmed)) {
        textWidget = Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(width: 4, color: primaryColor)),
          ),
          child: Text(
            trimmed,
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        );
      } else if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
        textWidget = Container(
          padding: const EdgeInsets.only(left: 16, right: 8, top: 2, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (RegExp(r'^[📉⏱️🏪📖🕐💰]').hasMatch(trimmed)) {
        textWidget = Container(
          padding: const EdgeInsets.only(left: 16, right: 8, top: 2, bottom: 2),
          child: Text(
            trimmed,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      } else {
        textWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            trimmed,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 13,
              height: 1.4,
            ),
          ),
        );
      }

      widgets.add(textWidget);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Dialog ketika server offline saat analisis.
  void _showServerOfflineDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Server Tidak Aktif',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak dapat menganalisis gambar karena server sedang tidak tersedia.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: Colors.grey[200]),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Tutup',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _checkServerStatus().then((_) {
                              if (_isServerReachable) _analyzeImage();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Dialog error analisis gambar.
  void _showAnalyzeErrorDialog(Object e) {
    String errorMessage = 'Gagal menganalisis gambar';
    final message = e.toString();
    if (message.contains('SocketException') ||
        message.contains('Connection refused') ||
        message.contains('Connection timed out')) {
      errorMessage =
          'Server tidak dapat dijangkau. Periksa koneksi internet atau server sedang tidak aktif.';
    } else if (message.contains('500')) {
      errorMessage = 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 10),
                Text('Gagal Terhubung'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage),
                const SizedBox(height: 10),
                Text(
                  'Detail: ${message.substring(0, min(100, message.length))}...',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _analyzeImage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
    );
  }

  /// Menampilkan gambar history (zoomable).
  void _showFullScreenHistoryImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(color: Colors.transparent),
                ),
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.95,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: primaryColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Memuat gambar...',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            errorBuilder:
                                (_, __, ___) => Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: Colors.red[300],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Gagal memuat gambar',
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Tutup',
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  /// Menampilkan gambar penuh yang dipilih user (mode diagnosa baru).
  void _showFullScreenSelectedImage(BuildContext context) {
    if (_selectedImage == null) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(color: Colors.transparent),
                ),
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.95,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Tutup',
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  /// Widget image riwayat (dengan future cached).
  Widget _buildHistoryImageView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[50]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: FutureBuilder<String?>(
          future: _historyImageUrlFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingImage();
            }
            if (snapshot.hasData && snapshot.data != null) {
              return _buildNetworkImage(snapshot.data!);
            }
            return _buildPlaceholderImage();
          },
        ),
      ),
    );
  }

  Future<String?> _getImageUrl(String predictionId) async {
    try {
      return await ApiService().getImageUrl(predictionId);
    } catch (_) {
      return null;
    }
  }

  /// Menampilkan network image + badge riwayat.
  Widget _buildNetworkImage(String imageUrl) {
    final fullImageUrl = '${ApiService.baseUrl}$imageUrl';
    return GestureDetector(
      onTap: () => _showFullScreenHistoryImage(context, fullImageUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                fullImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _buildLoadingImage();
                },
                errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.history, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Riwayat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat gambar riwayat...',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pastikan koneksi internet stabil',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 28,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gambar Diagnosa',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              if (widget.historyItem != null)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth - 24,
                  ),
                  child: Text(
                    widget.historyItem!.imageFilename,
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Widget picker gambar (mode diagnosa baru).
  Widget _buildImagePickerView() {
    if (_selectedImage == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              'Tambahkan gambar daun padi',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'untuk diagnosa',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showFullScreenSelectedImage(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Menampilkan panel hasil prediksi & top 3.
  Widget _buildPredictionResult() {
    final result = _predictionResult;
    if (result == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  accentColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.science_outlined,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hasil Diagnosa',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          if (widget.isHistoryMode) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Riwayat',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.predictedClass,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        result.confidencePercentage > 70
                            ? Colors.green.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color:
                          result.confidencePercentage > 70
                              ? Colors.green.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${result.confidencePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color:
                          result.confidencePercentage > 70
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top 3 Predictions
          if (result.hasTopPredictions) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.bar_chart,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.isHistoryMode
                              ? 'Top 3 Hasil Diagnosa (Riwayat)'
                              : 'Top 3 Kemungkinan Penyakit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (widget.isHistoryMode)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${result.topPredictions?.length ?? 0}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...result.top3Predictions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final prediction = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            index == 0
                                ? primaryColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              index == 0
                                  ? primaryColor.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color:
                                  index == 0 ? primaryColor : Colors.grey[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              prediction.className,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    index == 0
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(
                                prediction.confidence,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${prediction.confidence.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getConfidenceColor(
                                  prediction.confidence,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (widget.isHistoryMode) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Top 3 prediksi tidak tersedia untuk riwayat ini',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Expert Advice
          if (result.expertAdvice != null && result.expertAdvice!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Saran Ahli Penyuluhan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFormattedExpertAdvice(result.expertAdvice!),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  /// Panel chat (pesan dan input).
  Widget _buildChatSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return AnimatedBuilder(
      animation: _chatAnimation,
      builder: (_, __) {
        return Container(
          height:
              _isChatMinimized
                  ? 60
                  : (_isChatFullScreen
                      ? screenHeight * 0.75
                      : screenHeight * (isSmallScreen ? 0.4 : 0.5)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: _toggleChat,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.isHistoryMode
                            ? 'Konsultasi Lanjutan'
                            : 'Konsultasi Ahli',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.isHistoryMode) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Riwayat',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _isChatMinimized ? 0.5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_isChatMinimized)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child:
                            _messages.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 60,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          widget.isHistoryMode
                                              ? 'Lanjutkan konsultasi'
                                              : 'Mulai konsultasi dengan AI',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          widget.isHistoryMode
                                              ? 'Tanyakan lebih lanjut tentang ${_predictionResult?.predictedClass ?? "diagnosa ini"}'
                                              : 'Tanyakan tentang penyakit yang terdeteksi\natau cara pengobatannya',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  controller: _chatScrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  itemCount: _messages.length,
                                  itemBuilder: (_, i) {
                                    final msg = _messages[i];
                                    final isUser = msg['isUser'] as bool;
                                    final isExpertAdvice =
                                        msg['isExpertAdvice'] as bool? ?? false;
                                    final isError =
                                        msg['isError'] as bool? ?? false;
                                    final timestamp =
                                        msg['timestamp'] as DateTime? ??
                                        DateTime.now();

                                    return Align(
                                      alignment:
                                          isUser
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.85,
                                        ),
                                        margin: EdgeInsets.only(
                                          top: 4,
                                          bottom: 4,
                                          left: isUser ? 20 : 0,
                                          right: isUser ? 0 : 20,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isUser
                                                  ? userBubbleColor
                                                  : (isError
                                                      ? Colors.red.withOpacity(
                                                        0.1,
                                                      )
                                                      : (isExpertAdvice
                                                          ? primaryColor
                                                              .withOpacity(0.1)
                                                          : botBubbleColor)),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ).copyWith(
                                            bottomRight:
                                                isUser
                                                    ? const Radius.circular(4)
                                                    : null,
                                            bottomLeft:
                                                !isUser
                                                    ? const Radius.circular(4)
                                                    : null,
                                          ),
                                          border:
                                              isExpertAdvice
                                                  ? Border.all(
                                                    color: primaryColor
                                                        .withOpacity(0.3),
                                                  )
                                                  : (isError
                                                      ? Border.all(
                                                        color: Colors.red
                                                            .withOpacity(0.3),
                                                      )
                                                      : null),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (isError) ...[
                                              Row(
                                                children: const [
                                                  Icon(
                                                    Icons.error_outline,
                                                    size: 14,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Kesalahan Koneksi',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                            ],
                                            isUser
                                                ? Text(
                                                  msg['message'],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    height: 1.4,
                                                  ),
                                                )
                                                : _buildFormattedExpertAdvice(
                                                  msg['message'],
                                                ),
                                            const SizedBox(height: 4),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                _formatTimestamp(timestamp),
                                                style: TextStyle(
                                                  color:
                                                      isUser
                                                          ? Colors.white
                                                              .withOpacity(0.7)
                                                          : Colors.black54,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                      if (_isChatLoading)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'AI Ahli sedang mengetik...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Input (aktif juga pada history mode)
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, -1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      widget.isHistoryMode
                                          ? 'Tanyakan lebih lanjut...'
                                          : 'Ketik pertanyaan...',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(color: accentColor),
                                  ),
                                ),
                                minLines: 1,
                                maxLines: 3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: _isChatLoading ? null : _sendMessage,
                                tooltip: 'Kirim Pesan',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Navigasi ke mode diagnosa baru (reset).
  void _navigateToNewDiagnosis() {
    if (widget.isHistoryMode) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const PredictionChatScreen(isHistoryMode: false),
        ),
        (route) => route.isFirst,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PredictionChatScreen(isHistoryMode: false),
        ),
      );
    }
  }

  void _navigateToHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.isHistoryMode ? 'Detail Riwayat' : 'Diagnosa & Konsultasi',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!_isServerReachable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Server Offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        centerTitle: true,
        elevation: 2,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isServerReachable)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _checkServerStatus,
              tooltip: 'Periksa Koneksi Server',
            ),
          if (!widget.isHistoryMode)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _navigateToHistory,
              tooltip: 'Lihat Riwayat',
            ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              // Konten utama scroll
              Expanded(
                child: SingleChildScrollView(
                  controller: _mainScrollController,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (widget.isHistoryMode &&
                                widget.historyItem != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: primaryColor.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Diagnosa pada ${DateFormat('dd MMMM yyyy, HH:mm').format(widget.historyItem!.createdAt)}',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double imageHeight;
                                if (widget.isHistoryMode) {
                                  imageHeight =
                                      MediaQuery.of(context).size.height * 0.15;
                                  imageHeight = imageHeight.clamp(100.0, 160.0);
                                } else if (_predictionResult != null) {
                                  imageHeight = 120;
                                } else {
                                  imageHeight = 200;
                                }

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: imageHeight,
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(16),
                                  child:
                                      widget.isHistoryMode
                                          ? _buildHistoryImageView()
                                          : _buildImagePickerView(),
                                );
                              },
                            ),
                            if (!widget.isHistoryMode) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            () =>
                                                _pickImage(ImageSource.camera),
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          size: 18,
                                        ),
                                        label: const Text('Kamera'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            () =>
                                                _pickImage(ImageSource.gallery),
                                        icon: const Icon(
                                          Icons.photo_library,
                                          size: 18,
                                        ),
                                        label: const Text('Galeri'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedImage != null)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    child: ElevatedButton(
                                      onPressed:
                                          (_selectedImage == null ||
                                                  _isAnalyzing)
                                              ? null
                                              : _analyzeImage,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _isAnalyzing
                                                ? primaryColor.withOpacity(0.7)
                                                : primaryColor,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            Colors.grey[300],
                                        disabledForegroundColor:
                                            Colors.grey[600],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: _isAnalyzing ? 0 : 2,
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child:
                                            _isAnalyzing
                                                ? Row(
                                                  key: const ValueKey(
                                                    'loading',
                                                  ),
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 2.0,
                                                          ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Menganalisis...',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                : Row(
                                                  key: const ValueKey(
                                                    'analyze',
                                                  ),
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                      Icons.science_outlined,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Analisis Penyakit',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                      if (_predictionResult != null) _buildPredictionResult(),
                      if (_predictionResult != null && _isChatMinimized)
                        const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              if (_predictionResult != null) _buildChatSection(),
            ],
          ),
        ),
      ),
    );
  }
}
