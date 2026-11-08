import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/data/models/user_model.dart';
import 'package:petanitech_mobile/logic/blocs/user/user_bloc.dart';
import 'package:petanitech_mobile/modules/ecommerce/logic/controllers/order_controller.dart';
import 'package:petanitech_mobile/modules/ecommerce/logic/models/order_model.dart';
import 'package:petanitech_mobile/modules/ecommerce/presentation/order_history_screen.dart';
import 'package:petanitech_mobile/presentation/components/button.dart';
import 'package:petanitech_mobile/presentation/components/textfield.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';

const _green = Color(0xFF7CB35A);
const _lightGreen = Color(0xFFE8F1E2);
const _darkGreen = Color(0xFF5E963F);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final OrderController _orderCtrl = orderController;

  @override
  void initState() {
    super.initState();
    _orderCtrl.addListener(_refresh);
  }

  @override
  void dispose() {
    _orderCtrl.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      bloc: Modular.get<UserBloc>(),
      builder: (context, state) {
        if (state is UserLoaded) {
          final user = state.user;
          return SingleChildScrollView(
            child: Column(
              children: [
                _profileHeader(context, user),
                const SizedBox(height: 20),
                _myOrdersSection(context, _orderCtrl),
                const SizedBox(height: 20),
                _personalInformation(context, user),
                const SizedBox(height: 24),
                _utilitiesPanel(),
                const SizedBox(height: 40),
              ],
            ),
          );
        } else if (state is UserError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Modular.get<UserBloc>().add(LoadUser()),
                    child: const Text('Muat Ulang Profil'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

Widget _profileHeader(BuildContext context, UserModel user) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: Consts.padding),
    decoration: BoxDecoration(
      color: AppTheme.accentColor,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16.0),
        bottomRight: Radius.circular(16.0),
      ),
    ),
    child: Column(
      children: [
        GestureDetector(
          onTap: () => _showEditProfileSheet(context),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 4, color: Colors.white),
                  color: Colors.white,
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      (user.avatar != null && user.avatar!.trim().isNotEmpty)
                          ? CachedNetworkImageProvider(
                              ApiClient.getAsset(user.avatar!.trim()),
                            )
                          : null,
                  child: (user.avatar == null || user.avatar!.trim().isEmpty)
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isEmpty
              ? (user.email ?? 'Petani')
              : '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// ─── My Orders Section ────────────────────────────────────────────────────────

Widget _myOrdersSection(BuildContext context, OrderController ctrl) {
  final awaitingCount = ctrl.countByStatus(OrderStatus.awaitingPayment);
  final processingCount = ctrl.countByStatus(OrderStatus.processing);
  final shippedCount = ctrl.countByStatus(OrderStatus.shipped);
  final reviewCount = ctrl.unreviewedCompletedOrders.length;

  void goToHistory([OrderStatus? status]) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => OrderHistoryScreen(
          initialStatus: status,
          controller: ctrl,
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: Consts.padding16),
    child: Container(
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: _darkGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Pesanan Saya',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => goToHistory(),
                  child: const Row(
                    children: [
                      Text(
                        'Lihat Riwayat',
                        style: TextStyle(
                          color: _darkGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right, color: _darkGreen, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Shortcut row
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
            child: Row(
              children: [
                _orderShortcut(
                  icon: Icons.payment_rounded,
                  label: 'Belum Bayar',
                  badge: awaitingCount,
                  badgeColor: const Color(0xFFE69B26),
                  onTap: () => goToHistory(OrderStatus.awaitingPayment),
                ),
                _orderShortcut(
                  icon: Icons.inventory_2_outlined,
                  label: 'Diproses',
                  badge: processingCount,
                  badgeColor: const Color(0xFF3978C5),
                  onTap: () => goToHistory(OrderStatus.processing),
                ),
                _orderShortcut(
                  icon: Icons.local_shipping_outlined,
                  label: 'Dikirim',
                  badge: shippedCount,
                  badgeColor: const Color(0xFF7B61B5),
                  onTap: () => goToHistory(OrderStatus.shipped),
                ),
                _orderShortcut(
                  icon: Icons.star_outline_rounded,
                  label: 'Beri Penilaian',
                  badge: reviewCount,
                  badgeColor: _darkGreen,
                  onTap: () => goToHistory(OrderStatus.completed),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _orderShortcut({
  required IconData icon,
  required String label,
  required int badge,
  required Color badgeColor,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 26, color: _darkGreen),
                ),
                if (badge > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _personalInformation(BuildContext context, UserModel user) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: Consts.padding16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          tr('profile.personal_information'),
          trailing: GestureDetector(
            onTap: () => _showEditProfileSheet(context),
            child: Text(
              tr('profile.edit'),
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        _infoTile(Icons.email, tr('profile.email'), '${user.email}'),
        _infoTile(Icons.phone_android, tr('profile.phone'), user.phone ?? '-'),
        _infoTile(
          Icons.location_on,
          tr('profile.address'),
          user.location ?? '-',
        ),
      ],
    ),
  );
}

Widget _infoTile(IconData icon, String label, String value) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 2),
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: Consts.paddingVertical,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F3F5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.accentColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.accentColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _utilitiesPanel() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: Consts.padding16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(tr('profile.other')),
        SizedBox(height: 8),
        _utilityTile(
          Icons.help_outline,
          tr('profile.help'),
          onTap: () {
            debugPrint(tr('profile.help'));
          },
        ),
        _utilityTile(
          Icons.info_outline,
          tr('profile.about_app'),
          onTap: () {
            debugPrint('clicks');
          },
        ),
        _utilityTile(
          Icons.logout,
          tr('profile.logout'),
          onTap: () {
            debugPrint('logout');
          },
        ),
      ],
    ),
  );
}

Widget _utilityTile(IconData icon, String label, {VoidCallback? onTap}) {
  final bool isLogout = label.toLowerCase() == 'logout';

  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: isLogout ? Colors.red : AppTheme.accentColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isLogout ? Colors.red : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: isLogout ? Colors.red : Colors.grey),
        ],
      ),
    ),
  );
}

Widget _sectionTitle(String title, {Widget? trailing}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (trailing != null)
        Row(
          children: [
            const Icon(Icons.edit, color: AppTheme.accentColor, size: 14),
            const SizedBox(width: 4),
            trailing,
          ],
        ),
    ],
  );
}

void _showEditProfileSheet(BuildContext context) {
  final userBloc = Modular.get<UserBloc>();
  if (userBloc.state is! UserLoaded) return;
  final user = (userBloc.state as UserLoaded).user;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _EditProfileSheet(user: user),
  );
}

class _EditProfileSheet extends StatefulWidget {
  final UserModel user;
  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController locationController;

  XFile? _selectedImage;
  Uint8List? _selectedBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    nameController = TextEditingController(
      text: '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
    );
    phoneController = TextEditingController(text: user.phone ?? '');
    locationController = TextEditingController(text: user.location ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _selectedBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _saveProfile() {
    final userBloc = Modular.get<UserBloc>();
    final trimmed = nameController.text.trim();
    final names = trimmed.isNotEmpty ? trimmed.split(' ') : <String>[];
    final firstName = names.isNotEmpty ? names.first : '';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    setState(() {
      _isLoading = true;
    });

    userBloc.add(
      UpdateUser(
        firstName: firstName,
        lastName: lastName,
        phone: phoneController.text.trim(),
        avatar: widget.user.avatar,
        avatarFile: _selectedImage,
        location: locationController.text.trim(),
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final hasCurrentAvatar =
        user.avatar != null && user.avatar!.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        top: Consts.padding16,
        left: Consts.padding16,
        right: Consts.padding16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 42,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xCCCCCCCC),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.edit,
                    color: AppTheme.accentColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tr('profile.edit'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                child: const Icon(Icons.close, color: Color(0xCCCCCCCC)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Photo picker widget
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 3,
                                    color: AppTheme.accentColor,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _selectedBytes != null
                                      ? MemoryImage(_selectedBytes!)
                                      : (hasCurrentAvatar
                                          ? CachedNetworkImageProvider(
                                              ApiClient.getAsset(
                                                user.avatar!.trim(),
                                              ),
                                            )
                                          : null) as ImageProvider?,
                                  child: (_selectedBytes == null &&
                                          !hasCurrentAvatar)
                                      ? const Icon(
                                          Icons.person,
                                          size: 46,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 16,
                            color: AppTheme.accentColor,
                          ),
                          label: Text(
                            _selectedImage != null
                                ? 'Ubah Gambar (${_selectedImage!.name})'
                                : 'Pilih Foto dari Galeri',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PTTextField(
                    hintText: tr('profile.name'),
                    icon: Icons.person,
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  PTTextField(
                    hintText: tr('profile.phone'),
                    icon: Icons.phone,
                    controller: phoneController,
                  ),
                  const SizedBox(height: 16),
                  PTTextField(
                    hintText: tr('profile.location'),
                    icon: Icons.location_city,
                    controller: locationController,
                  ),
                  const SizedBox(height: 32),
                  PTButton(
                    label: _isLoading ? 'Menyimpan...' : tr('profile.save'),
                    onPressed: _isLoading ? () {} : _saveProfile,
                    styleBuilder: PrimaryButtonStyleBuilder(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
