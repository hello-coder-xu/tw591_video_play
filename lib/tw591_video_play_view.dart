import 'package:flutter/material.dart';
import 'package:tw591_video_play/helper/tw591_video_play_helper.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:tw591_video_play/widget/tw591_facebook_play_view.dart';
import 'package:tw591_video_play/widget/tw591_other_play_view.dart';
import 'package:tw591_video_play/widget/tw591_youtube_play_view.dart';

/// 播放器
class Tw591VideoPlayView extends StatelessWidget {
  final String initUrl;
  final bool mute;
  final bool loop;
  final bool autoPlay;
  final Tw591PlayController playController;

  const Tw591VideoPlayView({
    Key? key,
    required this.playController,
    required this.initUrl,
    this.mute = true,
    this.loop = true,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 设置视频类型
    VideoPlayType type = Tw591VideoPlayHelper.getUrlType(initUrl);
    playController.videoType = type;
    switch (type) {
      case VideoPlayType.youtube:
        return Tw591YoutubePlayView(
          initUrl: initUrl,
          mute: mute,
          loop: loop,
          autoPlay: autoPlay,
          playController: playController,
        );
      case VideoPlayType.facebook:
        return Tw591FacebookPlayView(
          initUrl: initUrl,
          mute: mute,
          loop: loop,
          autoPlay: autoPlay,
          playController: playController,
        );
      case VideoPlayType.other:
        return Tw591OtherPlayView(
          initUrl: initUrl,
          mute: mute,
          loop: loop,
          playController: playController,
        );
    }
  }
}
