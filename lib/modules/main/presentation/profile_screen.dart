import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
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
    final userBloc = Modular.get<UserBloc>();
    if (userBloc.state is UserLoaded) {
      final user = (userBloc.state as UserLoaded).user;
      return SingleChildScrollView(
        child: Column(
          children: [
            _profileHeader(user),
            const SizedBox(height: 20),
            _myOrdersSection(context, _orderCtrl),
            const SizedBox(height: 20),
            _personalInformation(context, user),
            const SizedBox(height: 20),
            _utilitiesPanel(),
            const SizedBox(height: 40),
          ],
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}

Widget _profileHeader(UserModel user) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: Consts.padding),
    decoration: BoxDecoration(
      color: AppTheme.accentColor,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(16.0),
        bottomRight: Radius.circular(16.0),
      ),
    ),
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 4, color: Colors.white),
            backgroundBlendMode: BlendMode.srcOver,
            color: Colors.white,
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              ApiClient.getAsset(user.avatar ?? ''),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${user.firstName} ${user.lastName}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
            debugPrint('about_app');
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final userBloc = Modular.get<UserBloc>();
  final user = (userBloc.state as UserLoaded).user;
  nameController.text = '${user.firstName} ${user.lastName}';
  emailController.text = user.email ?? '';
  phoneController.text = user.phone ?? '';
  locationController.text = user.location ?? '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
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
                color: Color(0xCCCCCCCC),
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
                      style: TextStyle(
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
            SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PTTextField(
                      hintText: tr('profile.name'),
                      icon: Icons.person,
                      controller: nameController,
                    ),
                    SizedBox(height: 16),
                    PTTextField(
                      hintText: tr('profile.email'),
                      icon: Icons.email,
                      controller: emailController,
                    ),
                    SizedBox(height: 16),
                    PTTextField(
                      hintText: tr('profile.phone'),
                      icon: Icons.phone,
                      controller: phoneController,
                    ),
                    SizedBox(height: 16),
                    PTTextField(
                      hintText: tr('profile.location'),
                      icon: Icons.location_city,
                      controller: locationController,
                    ),
                    SizedBox(height: 32),
                    PTButton(
                      label: tr('profile.save'),
                      onPressed: () {},
                      styleBuilder: PrimaryButtonStyleBuilder(),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
