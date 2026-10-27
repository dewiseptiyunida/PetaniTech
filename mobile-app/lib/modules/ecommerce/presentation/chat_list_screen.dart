import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  static int get unreadCount =>
      _ChatListScreenState._chats
          .where((chat) => chat['unread'] == true)
          .length;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E9);

  final TextEditingController _searchController = TextEditingController();

  int _selectedTab = 0;

  static final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Toko Tani Makmur',
      'message': 'Pupuk NPK-nya masih tersedia, Kak?',
      'date': '08:15',
      'initial': 'TM',
      'color': 0xFF388E3C,
      'unread': true,
      'active': true,
    },
    {
      'name': 'Agri Jaya Store',
      'message': 'Baik, pesanan segera kami proses.',
      'date': 'Kemarin',
      'initial': 'AJ',
      'color': 0xFF558B2F,
      'unread': false,
      'active': true,
    },
    {
      'name': 'Benih Padi Unggul',
      'message': 'Terima kasih sudah berbelanja!',
      'date': '08/10/26',
      'initial': 'BP',
      'color': 0xFF8D6E63,
      'unread': false,
      'active': false,
    },
    {
      'name': 'Pusat Pupuk Indonesia',
      'message': 'Untuk pengiriman estimasinya 2–3 hari.',
      'date': '07/10/26',
      'initial': 'PI',
      'color': 0xFF1976D2,
      'unread': true,
      'active': false,
    },
    {
      'name': 'Alat Pertanian Sejahtera',
      'message': 'Ada diskon untuk pembelian cangkul.',
      'date': '05/10/26',
      'initial': 'AS',
      'color': 0xFFEF8C32,
      'unread': false,
      'active': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredChats {
    final query = _searchController.text.toLowerCase().trim();

    return _chats.where((chat) {
      final matchesTab = _selectedTab == 0 || chat['active'] == true;

      final matchesSearch =
          chat['name'].toString().toLowerCase().contains(query) ||
          chat['message'].toString().toLowerCase().contains(query);

      return matchesTab && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chats = _filteredChats;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen, size: 28),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Chat',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildTabs(),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Expanded(
            child:
                chats.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: chats.length,
                      separatorBuilder:
                          (_, __) => const Divider(
                            height: 1,
                            indent: 88,
                            color: Color(0xFFEEEEEE),
                          ),
                      itemBuilder: (context, index) {
                        return _buildChatItem(chats[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Cari toko atau percakapan...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: primaryGreen),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close),
                  )
                  : null,
          filled: true,
          fillColor: const Color(0xFFF5F7F5),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Row(
        children: [
          _buildTab('Semua', 0),
          const SizedBox(width: 12),
          _buildTab('Aktif', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final selected = _selectedTab == index;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? lightGreen : const Color(0xFFF3F4F3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFFC8E6C9) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected ? primaryGreen : Colors.black54,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
            if (index == 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    final bool unread = chat['unread'] as bool;
    final Color avatarColor = Color(chat['color'] as int);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(storeName: chat['name'] as String),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: avatarColor.withOpacity(0.12),
                  child: Text(
                    chat['initial'] as String,
                    style: TextStyle(
                      color: avatarColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                if (chat['active'] == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w600,
                            color: const Color(0xFF252925),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        chat['date'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: unread ? primaryGreen : Colors.grey.shade500,
                          fontWeight:
                              unread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['message'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                unread ? Colors.black87 : Colors.grey.shade600,
                            fontWeight:
                                unread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 42,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada percakapan',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 1
                  ? 'Belum ada toko yang aktif.'
                  : 'Percakapan dengan penjual akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
