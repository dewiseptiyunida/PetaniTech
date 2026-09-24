import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/data/models/user_model.dart';
import 'package:petanitech_mobile/logic/blocs/user/user_bloc.dart';
import 'package:petanitech_mobile/presentation/components/button.dart';
import 'package:petanitech_mobile/presentation/components/textfield.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            _personalInformation(context, user),
            const SizedBox(height: 24),
            _utilitiesPanel(),
            const SizedBox(height: 40),
          ],
        ),
      );
    } else {
      return CircularProgressIndicator();
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
            print('clicks');
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
