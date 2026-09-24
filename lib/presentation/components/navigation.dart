import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_module.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/logic/blocs/navigation/navigation_bloc.dart';
import 'package:petanitech_mobile/logic/blocs/navigation/navigation_event.dart';
import 'package:petanitech_mobile/logic/blocs/navigation/navigation_state.dart';

class PTNavigation extends StatefulWidget {
  const PTNavigation({super.key});

  @override
  State<PTNavigation> createState() => _PTNavigationState();
}

class _PTNavigationState extends State<PTNavigation> {
  int _tabIndex = 0;

  int get tabIndex => _tabIndex;

  set tabIndex(int v) {
    _tabIndex = v;
    Modular.get<NavigationBloc>().add(
      NavigationSelectTab(tab: NavigationTab.values[v]),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CircleNavBar(
      height: 50,
      activeIcons:
          Consts.bottomNavigation.map((e) => e["active"] as Icon).toList(),
      inactiveIcons:
          Consts.bottomNavigation.map((e) => e["inactive"] as Icon).toList(),
      levels: Consts.bottomNavigation.map((e) => e["name"] as String).toList(),
      activeLevelsStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      inactiveLevelsStyle: const TextStyle(fontSize: 12, color: Colors.white70),
      circleWidth: 35,
      cornerRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
      circleColor: AppTheme.accentColor,
      color: AppTheme.accentColor,
      tabCurve: Curves.decelerate,
      iconCurve: Easing.linear,
      tabDurationMillSec: 500,
      iconDurationMillSec: 100,
      activeIndex: tabIndex,
      onTap: (index) {
        tabIndex = index;
        Modular.to.navigate(
          AppModule.mainRoute + Consts.bottomNavigation[index]["url"]!,
        );
      },
    );
  }
}
