import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/app_module.dart';
import 'package:petanitech_mobile/core/consts.dart';
import 'package:petanitech_mobile/data/models/post_model.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_bloc.dart';
import 'package:petanitech_mobile/modules/main/logic/blocs/home/home_state.dart';
import 'package:petanitech_mobile/modules/post/post_module.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import 'package:shimmer/shimmer.dart';

class HomePost extends StatefulWidget {
  const HomePost({super.key});

  @override
  HomePostState createState() => HomePostState();
}

class HomePostState extends State<HomePost> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Modular.get<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: Consts.padding16,
                  right: Consts.padding16,
                  top: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Berita",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "terbaru",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0),
                        overlayColor: Colors.transparent,
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      clipBehavior: Clip.none,
                      onPressed:
                          () => Modular.to.pushNamed(
                            AppModule.postRoute + PostModule.indexRoute,
                          ),
                      label: Text("Lihat Semua"),
                      iconAlignment: IconAlignment.end,
                      icon: Icon(Icons.arrow_forward_ios, size: 12),
                    ),
                  ],
                ),
              ),
              state is HomeLoaded
                  ? _listPost(context, state.posts)
                  : _shimmerList(state is! HomeLoaded),
            ],
          );
        },
      ),
    );
  }
}

Widget _listPost(BuildContext context, List<PostModel> posts) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(posts.length, (index) {
        return _itemList(context, index, posts.length, posts[index]);
      }),
    ),
  );
}

Widget _itemList(BuildContext context, int index, int total, PostModel post) {
  return Container(
    margin: EdgeInsets.all(
      8,
    ).copyWith(left: index == 0 ? 16 : 8, right: index == total - 1 ? 16 : 8),
    height: 200,
    child: ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: GestureDetector(
        onTap: () {
          Modular.to.pushNamed(
            AppModule.postRoute +
                PostModule.postDetailRoute.replaceFirst(':id', post.id),
          );
        },
        child: Stack(
          children: [
            Container(
              width: 160,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    ApiClient.getAsset(post.image?.id ?? ''),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(200)],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              post.title ?? 'Artikel',
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Text(
                              DateFormat.yMMMMd(
                                context.locale.toString(),
                              ).format(post.dateCreated ?? DateTime.now()),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _shimmerList(bool enable) {
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
            width: 160,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    ),
  );
}
