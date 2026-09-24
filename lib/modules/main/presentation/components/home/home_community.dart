import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/data/models/community_model.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_bloc.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_state.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import 'package:shimmer/shimmer.dart';

class HomeCommunity extends StatefulWidget {
  const HomeCommunity({super.key});

  @override
  State<HomeCommunity> createState() => _HomeCommunityState();
}

class _HomeCommunityState extends State<HomeCommunity> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: Consts.padding16,
            right: Consts.padding16,
            top: 32.0,
            bottom: 8,
          ),
          child: Text(
            "Komunitas",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        BlocBuilder<HomeBloc, HomeState>(
          bloc: Modular.get<HomeBloc>(),
          builder:
              (context, state) =>
                  state is HomeLoaded
                      ? _listCommunity(state.communities)
                      : _shimmerList(),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              // Add your button action here
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.accentColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            child: Center(
              child: Text(
                'Lihat Semua Komunitas',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _listCommunity(List<CommunityModel> communities) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: Consts.padding16),
      itemCount: communities.length,
      itemBuilder: (context, index) {
        final community = communities[index];
        return _itemList(community);
      },
    );
  }

  Widget _itemList(CommunityModel community) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                // border: Border.all(width: 1, color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(125),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  ApiClient.getAsset(community.image),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      tr(community.visibility.trim()),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.circle, size: 4, color: Colors.grey[600]),
                    SizedBox(width: 5),
                    Text(
                      '${community.membersCount} Anggota',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Anda belum bisa bergabung dengan komunitas ini',
                      ),
                    ),
                  );
                },
              );
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              side: BorderSide(color: AppTheme.accentColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Gabung', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _shimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(bottom: 12, left: 16.0, right: 16.0),
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 25, backgroundColor: Colors.grey[300]),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Container(
              width: 70,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300]!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
