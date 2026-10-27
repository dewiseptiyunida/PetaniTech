import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'package:petanitech_mobile/data/models/post_model.dart';
import 'package:petanitech_mobile/modules/post/logic/blocs/post_detail/post_detail_bloc.dart';
import 'package:petanitech_mobile/modules/post/logic/blocs/post_detail/post_detail_event.dart';
import 'package:petanitech_mobile/modules/post/logic/blocs/post_detail/post_detail_state.dart';
import 'package:petanitech_mobile/utils/client/api_client.dart';
import 'package:petanitech_mobile/utils/player/simple_youtube_player.dart';

class PostDetailScreen extends StatefulWidget {
  final String id;

  const PostDetailScreen({super.key, required this.id});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    Modular.get<PostDetailBloc>().add(LoadPostById(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Modular.get<PostDetailBloc>(),
      child: Scaffold(
        body: BlocBuilder<PostDetailBloc, PostDetailState>(
          builder: (context, state) {
            if (state is PostLoaded) {
              final post = state.post;
              return _a(context, post);
            } else if (state is PostError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

Widget _a(BuildContext context, PostModel post) {
  return Stack(
    children: [
      Stack(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(ApiClient.getAsset(post.image?.id ?? '')),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(50),
                    Colors.black.withAlpha(200),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'dd MMMM yyyy · hh:mm',
                          ).format(post.dateCreated ?? DateTime.now()),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.title ?? 'Judul Berita',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.white),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child:
                                (post.userCreated?.avatar == null || post.userCreated!.avatar!.isEmpty)
                                    ? Container(
                                      height: 25,
                                      width: 25,
                                      color: Colors.grey,
                                      child: const Icon(Icons.person, size: 16, color: Colors.white),
                                    )
                                    : Image.network(
                                      ApiClient.getAsset(
                                        post.userCreated!.avatar!,
                                      ),
                                      height: 25,
                                      width: 25,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${post.userCreated?.firstName ?? ''} ${post.userCreated?.lastName ?? ''}'.trim().isEmpty
                              ? 'Admin'
                              : '${post.userCreated?.firstName ?? ''} ${post.userCreated?.lastName ?? ''}'.trim(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppTheme.accentColor.withAlpha(0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Modular.to.pop(),
          ),
          actions: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.comment_outlined, color: Colors.white),
                  onPressed: () {},
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_outline, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 180),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                elevation: 0.0,
                margin: EdgeInsets.all(0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content
                      HtmlWidget(
                        post.content ?? 'Konten berita tidak tersedia',
                        customWidgetBuilder: (element) {
                          if (element.attributes['src']?.contains(
                                'youtube.com',
                              ) ??
                              false) {
                            return SimpleYoutubePlayer(
                              url: element.attributes['src']!,
                            );
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
