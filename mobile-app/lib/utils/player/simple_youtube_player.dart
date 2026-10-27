import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SimpleYoutubePlayer extends StatefulWidget {
  final String url;

  const SimpleYoutubePlayer({super.key, required this.url});

  @override
  State<SimpleYoutubePlayer> createState() => _SimpleYoutubePlayerState();
}

class _SimpleYoutubePlayerState extends State<SimpleYoutubePlayer> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.url) ?? '';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    )..addListener(() {
      if (_isPlayerReady && mounted) {
        setState(() {});
      }
    });
    _isPlayerReady = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
      builder:
          (context, player) => Column(
            children: [
              player,
              const SizedBox(height: 10),
              Text(
                _controller.metadata.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
    );
  }
}
