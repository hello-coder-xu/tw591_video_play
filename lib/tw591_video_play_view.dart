import 'package:flutter/material.dart';
import 'package:tw591_video_play/helper/tw591_video_play_helper.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:tw591_video_play/widget/tw591_controller_ui_view.dart';
import 'package:tw591_video_play/widget/tw591_facebook_play_view.dart';
import 'package:tw591_video_play/widget/tw591_other_play_view.dart';
import 'package:tw591_video_play/widget/tw591_youtube_play_view.dart';

typedef CustomView = Widget Function(VideoPlayStatus? videoPlayStatus);

/// 播放器
class Tw591VideoPlayView extends StatefulWidget {
  final String initUrl;
  final Function(Tw591PlayController?)? onViewCreated;
  final Function(Tw591PlayController?)? onDispose;
  final bool mute;
  final bool loop;
  final bool autoPlay;
  final bool displayUi;
  final CustomView? customView;

  const Tw591VideoPlayView({
    Key? key,
    required this.initUrl,
    this.onViewCreated,
    this.onDispose,
    this.mute = true,
    this.loop = true,
    this.autoPlay = true,
    this.displayUi = false,
    this.customView,
  }) : super(key: key);

  @override
  State<Tw591VideoPlayView> createState() => _Tw591VideoPlayViewState();
}

class _Tw591VideoPlayViewState extends State<Tw591VideoPlayView> {
  late Tw591PlayController controller;

  @override
  void initState() {
    super.initState();
    controller = Tw591PlayController();
    controller.isMute = widget.mute;
    controller.addListener(updateView);
    widget.onViewCreated?.call(controller);
  }

  /// 更新视图
  void updateView() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant Tw591VideoPlayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.removeListener(updateView);
    if (widget.initUrl != oldWidget.initUrl) {
      controller.reset();
    }

    if (widget.mute != oldWidget.mute) {
      controller.isMute = widget.mute;
    }
    controller.addListener(updateView);
  }

  @override
  void dispose() {
    controller.dispose();
    widget.onDispose?.call(controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = videoPlayView();
    result = Stack(
      children: [
        result,
        // 自定义视图
        widget.customView?.call(controller.videoPlayStatus) ??
            const SizedBox.shrink(),
        if (widget.displayUi) Tw591ControllerUiView(controller: controller),
      ],
    );
    return result;
  }

  /// 视频播放视图
  Widget videoPlayView() {
    // 设置视频类型
    VideoPlayType type = Tw591VideoPlayHelper.getUrlType(widget.initUrl);
    controller.videoType = type;
    final key = ValueKey(widget.initUrl);
    switch (type) {
      case VideoPlayType.youtube:
        return Tw591YoutubePlayView(
          key: key,
          initUrl: widget.initUrl,
          mute: widget.mute,
          loop: widget.loop,
          autoPlay: widget.autoPlay,
          playController: controller,
        );
      case VideoPlayType.facebook:
        return Tw591FacebookPlayView(
          key: key,
          initUrl: widget.initUrl,
          mute: widget.mute,
          loop: widget.loop,
          autoPlay: widget.autoPlay,
          playController: controller,
        );
      case VideoPlayType.other:
        return Tw591OtherPlayView(
          key: key,
          initUrl: widget.initUrl,
          mute: widget.mute,
          loop: widget.loop,
          autoPlay: widget.autoPlay,
          playController: controller,
        );
    }
  }
}
