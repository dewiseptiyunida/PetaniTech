import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:petanitech_mobile/core/app_module.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/core/assets.dart';
import 'package:petanitech_mobile/data/models/post_model.dart';
import 'package:petanitech_mobile/modules/post/logic/blocs/post/post_bloc.dart';
import 'package:petanitech_mobile/modules/post/logic/blocs/post/post_event.dart';
import 'package:petanitech_mobile/modules/post/post_module.dart';
import 'package:petanitech_mobile/modules/post/presentation/components/post_item.dart';
import 'package:petanitech_mobile/modules/post/presentation/components/post_item_shimmer.dart';
import 'package:petanitech_mobile/modules/post/presentation/components/post_search.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.accentColor,
        title: Text('Berita'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: PostSearchDelegate());
            },
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          Future.sync(() => Modular.get<PostBloc>().add(RefreshPosts()));
        },
        child: BlocBuilder<PostBloc, PagingState<int, PostModel>>(
          bloc: Modular.get<PostBloc>(),
          builder: (context, state) {
            return PagedListView<int, PostModel>(
              state: state,
              fetchNextPage: () {
                Modular.get<PostBloc>().add(LoadPosts());
                debugPrint(
                  "Ambil data baru with key : ${state.keys} || Apakah last : ${state.keys?.last}",
                );
              },
              builderDelegate: PagedChildBuilderDelegate(
                newPageProgressIndicatorBuilder:
                    (context) => const PostItemShimmer(),
                firstPageProgressIndicatorBuilder:
                    (context) => Column(
                      children: List.generate(
                        5,
                        (index) => const PostItemShimmer(),
                      ),
                    ),
                noMoreItemsIndicatorBuilder:
                    (context) => SizedBox(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(
                            children: [
                              Image.asset(
                                PTAsset.logo,
                                width: 30,
                                height: 30,
                                color: Colors.grey[300],
                              ),

                              Text(
                                'Tidak ada data lagi',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                noItemsFoundIndicatorBuilder:
                    (context) => Center(
                      child: Text(
                        'Tidak ada data',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                firstPageErrorIndicatorBuilder:
                    (context) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Terjadi kesalahan',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              Modular.get<PostBloc>().add(RefreshPosts());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              overlayColor: Colors.white,
                            ),
                            child: Text(
                              'Coba Lagi',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                newPageErrorIndicatorBuilder:
                    (context) => Center(
                      child: Text(
                        'Terjadi kesalahan saat mengambil data',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                invisibleItemsThreshold: 5,
                transitionDuration: const Duration(seconds: 1),
                animateTransitions: true,
                itemBuilder:
                    (context, item, index) => PostItem(
                      index: index,
                      id: item.id,
                      title: item.title ?? '',
                      image: item.image?.id ?? '',
                      date: DateFormat(
                        'dd MMMM yyyy · hh:mm',
                        context.locale.toString(),
                      ).format(item.dateCreated ?? DateTime.now()),
                      author:
                          '${item.userCreated?.firstName ?? ''} ${item.userCreated?.lastName ?? ''}',
                      authorImage: item.userCreated?.avatar ?? '',
                      onTapCallback:
                          (id) => Modular.to.pushNamed(
                            AppModule.postRoute +
                                PostModule.postDetailRoute.replaceFirst(
                                  ':id',
                                  id,
                                ),
                          ),
                    ),
              ),
            );
          },
        ),
      ),
    );
  }
}
