import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/logic/blocs/user/user_bloc.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_bloc.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_event.dart';
import 'package:petanitech_mobile/modules/main/presentation/components/home/home_commodity.dart';
import 'package:petanitech_mobile/modules/main/presentation/components/home/home_community.dart';
import 'package:petanitech_mobile/modules/main/presentation/components/home/home_post.dart';
import 'package:petanitech_mobile/modules/main/presentation/components/home/home_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Modular.get<HomeBloc>().add(RequestAll());
    Modular.get<UserBloc>().add(LoadUser());
  }

  Future<void> onRefresh() async {
    Modular.get<HomeBloc>().add(RequestAll());
    Modular.get<UserBloc>().add(LoadUser());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: Consts.paddingVertical,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                ),
              ),
              child: HomeSlider(),
            ),
            HomeCommodity(),
            HomePost(),
            HomeCommunity(),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
