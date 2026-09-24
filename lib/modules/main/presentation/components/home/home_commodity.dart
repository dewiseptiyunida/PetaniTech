import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/data/models/commodity_model.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_bloc.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_state.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import 'package:shimmer/shimmer.dart';

class HomeCommodity extends StatelessWidget {
  const HomeCommodity({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Modular.get<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: Consts.padding16,
                  right: Consts.padding16,
                  top: Consts.padding16,
                  bottom: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Komoditas",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              state is HomeLoaded
                  ? _listCommodities(state.commodities)
                  : _shimmerListCommodities(state is! HomeLoaded),
            ],
          );
        },
      ),
    );
  }
}

Widget _listCommodities(List<CommodityModel> commodities) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(
        commodities.length,
        (index) => Container(
          margin: EdgeInsets.all(8).copyWith(
            left: index == 0 ? 16 : 8,
            right: index == commodities.length - 1 ? 16 : 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Image.network(
                    ApiClient.getAsset(commodities[index].image),
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 70,
                height: 40,
                child: Text(
                  commodities[index].name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _shimmerListCommodities(bool enable) {
  return Shimmer.fromColors(
    enabled: enable,
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          return Container(
            margin: EdgeInsets.all(8).copyWith(
              left: index == 0 ? 16 : 8,
              right: index == 5 - 1 ? 16 : 8,
            ),
            child: Column(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 7),
                Container(
                  width: 50,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    ),
  );
}
