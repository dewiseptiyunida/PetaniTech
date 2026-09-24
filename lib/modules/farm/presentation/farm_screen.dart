import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/data/models/farm_model.dart';
import 'package:petanitech_mobile/modules/farm/logic/blocs/farm/farm_bloc.dart';
import 'package:petanitech_mobile/modules/farm/logic/blocs/farm/farm_event.dart';
import 'package:petanitech_mobile/modules/farm/presentation/components/item_farm.dart';
import 'package:petanitech_mobile/utils/coordinate/coordinate_helper.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key});

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  @override
  void initState() {
    super.initState();
    Modular.get<FarmBloc>().add(LoadFarms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lahan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add your onPressed logic here
            },
          ),
        ],
        backgroundColor: AppTheme.accentColor,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<FarmBloc, PagingState<int, FarmModel>>(
                bloc: Modular.get<FarmBloc>(),
                builder: (context, state) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      Future.sync(
                        () => Modular.get<FarmBloc>().add(RefreshFarms()),
                      );
                    },
                    child: PagedGridView(
                      state: state,
                      fetchNextPage: () {
                        Modular.get<FarmBloc>().add(LoadFarms());
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 100 / 135,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            crossAxisCount: 2,
                          ),
                      builderDelegate: PagedChildBuilderDelegate<FarmModel>(
                        itemBuilder:
                            (context, item, index) => ItemFarm(
                              title: item.name ?? '',
                              address: item.address ?? '',
                              size: double.parse(
                                item.areaSize ?? '0.0',
                              ).toStringAsFixed(2),
                              unit: tr('farm.unit.${item.areaUnit}'),
                              polygon: CoordinateHelper.convertToLatLng(
                                item.location?.coordinates?[0] ??
                                    [
                                      [0.0, 0.0],
                                    ],
                              ),
                            ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
