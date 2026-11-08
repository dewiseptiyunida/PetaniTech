import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_module.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/core/assets.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/logic/blocs/navigation/navigation_bloc.dart';
import 'package:petanitech_mobile/logic/blocs/navigation/navigation_event.dart';
import 'package:petanitech_mobile/logic/blocs/navigation/navigation_state.dart';
import 'package:petanitech_mobile/logic/blocs/user/user_bloc.dart';
import 'package:petanitech_mobile/modules/main/main_module.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import 'package:shimmer/shimmer.dart';

class PTAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PTAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userBloc = Modular.get<UserBloc>();
    if (userBloc.state is UserInitial) {
      userBloc.add(LoadUser());
    }

    return BlocProvider.value(
      value: userBloc,
      child: BlocBuilder<UserBloc, UserState>(
        bloc: userBloc,
        builder: (context, state) {
          return AppBar(
            backgroundColor: AppTheme.accentColor,
            title: Row(
              children: [
                Image.asset(PTAsset.logo, width: 30, height: 30),
                const SizedBox(width: 8),
                const Text(
                  "Petanitech",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ],
            ),
            shape: const Border(bottom: BorderSide.none),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: const Text(
                          '99',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<NavigationBloc, NavigationState>(
                bloc: Modular.get<NavigationBloc>(),
                builder: (context, stateNav) {
                  if (stateNav.currentTab != NavigationTab.profile) {
                    if (state is UserLoaded) {
                      final hasAvatar = state.user.avatar != null &&
                          state.user.avatar!.trim().isNotEmpty;
                      return GestureDetector(
                        onTap: () {
                          Modular.get<NavigationBloc>().add(
                            const NavigationSelectTab(
                              tab: NavigationTab.profile,
                            ),
                          );
                          Modular.to.navigate(
                            '${AppModule.mainRoute}${MainModule.profileRoute}',
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: Consts.padding16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.white24,
                            backgroundImage: hasAvatar
                                ? CachedNetworkImageProvider(
                                    ApiClient.getAsset(
                                      state.user.avatar!.trim(),
                                    ),
                                  )
                                : null,
                            child: !hasAvatar
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.only(right: Consts.padding16),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: const CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      );
                    }
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
