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
  final Tw591PlayController? playController;

  const Tw591VideoPlayView({
    Key? key,
    required this.initUrl,
    this.playController,
    this.mute = true,
    this.loop = true,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget result = videoPlayView();
        result = Stack(
          children: [
            result,
            // Positioned.fill(
            //   child: Container(
            //     color: Colors.black38,
            //   ),
            // ),
            // const Center(
            //   child: Icon(
            //     Icons.pause_circle_filled,
            //     size: 48,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        );
        return result;
      },
    );
  }

  /// 视频播放视图
  Widget videoPlayView() {
    // 设置视频类型
    VideoPlayType type = Tw591VideoPlayHelper.getUrlType(initUrl);
    playController?.videoType = type;
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
          autoPlay: autoPlay,
          playController: playController,
        );
    }
  }

  Widget playAndPauseBtnView() {
    return Container();
  }
}
