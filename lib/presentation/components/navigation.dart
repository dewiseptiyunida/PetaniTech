import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    final currentTab = Modular.get<NavigationBloc>().state.currentTab;
    final index = NavigationTab.values.indexOf(currentTab);
    if (index != -1) {
      _tabIndex = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      bloc: Modular.get<NavigationBloc>(),
      listener: (context, state) {
        final index = NavigationTab.values.indexOf(state.currentTab);
        if (index != -1 && index != _tabIndex) {
          setState(() {
            _tabIndex = index;
          });
        }
      },
      child: CircleNavBar(
        height: 50,
        activeIcons:
            Consts.bottomNavigation.map((e) => e["active"] as Icon).toList(),
        inactiveIcons:
            Consts.bottomNavigation.map((e) => e["inactive"] as Icon).toList(),
        levels:
            Consts.bottomNavigation.map((e) => e["name"] as String).toList(),
        activeLevelsStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        inactiveLevelsStyle: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
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
        activeIndex: _tabIndex,
        onTap: (index) {
          setState(() {
            _tabIndex = index;
          });
          Modular.get<NavigationBloc>().add(
            NavigationSelectTab(tab: NavigationTab.values[index]),
          );
          Modular.to.navigate(
            AppModule.mainRoute + Consts.bottomNavigation[index]["url"]!,
          );
        },
      ),
    );
  }
}
