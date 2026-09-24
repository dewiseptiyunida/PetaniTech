// lib/modules/disesase/presentation/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petanitech_mobile/modules/disesase/presentation/prediction_chat_screen.dart';
import '../logic/services/api_service.dart';
import '../logic/models/history_model.dart';

enum HistoryFilter { all, healthy, disease }

enum HistorySort { newest, oldest, confidence }

extension HistoryFilterLabel on HistoryFilter {
  String get label {
    switch (this) {
      case HistoryFilter.all:
        return 'Semua';
      case HistoryFilter.healthy:
        return 'Sehat';
      case HistoryFilter.disease:
        return 'Penyakit';
    }
  }
}

extension HistorySortLabel on HistorySort {
  String get label {
    switch (this) {
      case HistorySort.newest:
        return 'Terbaru';
      case HistorySort.oldest:
        return 'Terlama';
      case HistorySort.confidence:
        return 'Confidence';
    }
  }
}

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  // Data & pagination
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 20;
  List<PredictionHistoryItem> _historyItems = [];
  int _currentPage = 0;
  bool _hasMoreData = true;

  // UI state
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Filter & sort
  HistoryFilter _selectedFilter = HistoryFilter.all;
  HistorySort _selectedSort = HistorySort.newest;

  // Animations
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Theming
  final Color primaryColor = Colors.green.shade700;

  // Logging flag
  static const bool _enableLog = false;
  void _log(String msg) {
    if (_enableLog) debugPrint('[History] $msg');
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);
    _loadHistory();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) _loadMoreHistory();
    }
  }

  Future<void> _loadHistory({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _historyItems.clear();
        _hasMoreData = true;
        _errorMessage = null;
      });
    }
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getUserHistory(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      if (response != null && response.success) {
        setState(() {
          if (refresh) {
            _historyItems = response.history;
          } else {
            _historyItems.addAll(response.history);
          }
          _hasMoreData = response.pagination.hasMore;
          _errorMessage = null;
        });
        _startListAnimations();
      } else {
        setState(() {
          _errorMessage =
              response == null
                  ? 'Tidak dapat terhubung ke server'
                  : 'Gagal memuat riwayat';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startListAnimations() {
    _fadeController.forward(from: 0);
    _slideController.forward(from: 0);
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      final response = await _apiService.getUserHistory(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );
      if (response != null && response.success) {
        setState(() {
          _historyItems.addAll(response.history);
          _hasMoreData = response.pagination.hasMore;
        });
      } else {
        _currentPage--; // rollback
      }
    } catch (_) {
      _currentPage--;
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _navigateToNewDiagnosis() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PredictionChatScreen(isHistoryMode: false),
      ),
    );
  }

  Future<void> _deleteHistoryItem(PredictionHistoryItem item) async {
    try {
      final success = await _apiService.deleteHistoryItem(item.id);
      if (success) {
        setState(() {
          _historyItems.removeWhere((h) => h.id == item.id);
        });
        _showSnack('Riwayat berhasil dihapus', success: true);
      } else {
        _showSnack('Gagal menghapus riwayat');
      }
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? primaryColor : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(PredictionHistoryItem item) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Konfirmasi Hapus'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Anda yakin ingin menghapus riwayat diagnosa ini?'),
                const SizedBox(height: 8),
                _DeleteInfo(primaryColor: primaryColor),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _deleteHistoryItem(item);
                },
                child: const Text('Hapus Permanen'),
              ),
            ],
          ),
    );
  }

  void _navigateToDetail(PredictionHistoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PredictionChatScreen(historyItem: item, isHistoryMode: true),
      ),
    ).then((_) => _loadHistory(refresh: true));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) {
        HistoryFilter tempFilter = _selectedFilter;
        HistorySort tempSort = _selectedSort;

        return AlertDialog(
          title: const Text('Filter & Urutkan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...HistoryFilter.values.map(
                  (f) => RadioListTile<HistoryFilter>(
                    title: Text(f.label),
                    value: f,
                    groupValue: tempFilter,
                    onChanged: (v) => setState(() => tempFilter = v!),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Urutkan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...HistorySort.values.map(
                  (s) => RadioListTile<HistorySort>(
                    title: Text(s.label),
                    value: s,
                    groupValue: tempSort,
                    onChanged: (v) => setState(() => tempSort = v!),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = tempFilter;
                  _selectedSort = tempSort;
                });
                Navigator.pop(context);
              },
              child: const Text('Terapkan'),
            ),
          ],
        );
      },
    );
  }

  List<PredictionHistoryItem> _getFilteredHistory() {
    Iterable<PredictionHistoryItem> data = _historyItems;

    switch (_selectedFilter) {
      case HistoryFilter.all:
        break;
      case HistoryFilter.healthy:
        data = data.where((e) => e.diseaseCategory == 'Sehat');
        break;
      case HistoryFilter.disease:
        data = data.where((e) => e.diseaseCategory != 'Sehat');
        break;
    }

    final list = data.toList();
    switch (_selectedSort) {
      case HistorySort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case HistorySort.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case HistorySort.confidence:
        list.sort(
          (a, b) => b.confidencePercentage.compareTo(a.confidencePercentage),
        );
        break;
    }
    return list;
  }

  String _getAdvicePreview(String advice) {
    final cleanAdvice =
        advice
            .replaceAll(RegExp(r'[🦠🏠💡👁️⚠️🔧💊🛡️🌾🚨]'), '')
            .replaceAll(RegExp(r'\d+\.'), '')
            .trim();

    for (final sentence in cleanAdvice.split('\n')) {
      if (sentence.trim().isNotEmpty && sentence.trim().length > 20) {
        return sentence.trim();
      }
    }
    return cleanAdvice.length > 100
        ? '${cleanAdvice.substring(0, 100)}...'
        : cleanAdvice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Riwayat Diagnosa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter & Urutkan',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadHistory(refresh: true),
        color: primaryColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _historyItems.isEmpty) return _buildLoadingState();
    if (_errorMessage != null && _historyItems.isEmpty) {
      return _buildErrorState();
    }
    if (_historyItems.isEmpty) return _buildEmptyState();
    return _buildHistoryList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 16),
          Text(
            'Memuat riwayat...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat riwayat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Terjadi kesalahan tidak dikenal',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _loadHistory(refresh: true),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai diagnosa tanaman padi untuk melihat riwayat',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mulai Diagnosa'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final items = _getFilteredHistory();
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: items.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (_, index) {
            if (index == items.length) return _buildLoadingMoreIndicator();
            return _HistoryCard(
              item: items[index],
              onTap: () => _navigateToDetail(items[index]),
              onDelete: () => _showDeleteConfirmation(items[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: primaryColor),
    );
  }
}

// --- Stateless Helper Widgets ---

class _HistoryCard extends StatelessWidget {
  final PredictionHistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderRow(item: item, onDelete: onDelete),
                const SizedBox(height: 12),
                _DiseaseRow(item: item),
                if (item.chatMessages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ChatBadge(count: item.chatMessages.length),
                ],
                const SizedBox(height: 8),
                const _TapHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final PredictionHistoryItem item;
  final VoidCallback onDelete;

  const _HeaderRow({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.confidenceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${item.confidencePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: item.confidenceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.red[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DiseaseRow extends StatelessWidget {
  final PredictionHistoryItem item;
  const _DiseaseRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isHealthy = item.diseaseCategory == 'Sehat';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isHealthy
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isHealthy ? Icons.eco : Icons.warning,
            color: isHealthy ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.predictedClass,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                item.diseaseCategory,
                style: TextStyle(
                  fontSize: 12,
                  color: isHealthy ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ],
    );
  }
}

class _ChatBadge extends StatelessWidget {
  final int count;
  const _ChatBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat, size: 12, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            '$count pesan',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        'Tap untuk melihat detail lengkap',
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 10,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _DeleteInfo extends StatelessWidget {
  final Color primaryColor;
  const _DeleteInfo({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final warningStyle = TextStyle(fontSize: 12, color: Colors.red[700]);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• Data diagnosa akan dihapus permanen', style: warningStyle),
          Text(
            '• Gambar yang terkait akan dihapus dari server',
            style: warningStyle,
          ),
          Text('• Riwayat chat akan ikut terhapus', style: warningStyle),
          Text(
            '• Aksi ini tidak dapat dibatalkan',
            style: warningStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
