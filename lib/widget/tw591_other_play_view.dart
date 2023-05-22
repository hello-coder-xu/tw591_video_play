import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:video_player/video_player.dart';

class Tw591OtherPlayView extends StatefulWidget {
  final String initUrl;
  final bool mute;
  final bool loop;
  final bool autoPlay;
  final Tw591PlayController? playController;

  const Tw591OtherPlayView({
    super.key,
    required this.initUrl,
    this.mute = true,
    this.loop = true,
    this.autoPlay = false,
    this.playController,
  });

  @override
  State<Tw591OtherPlayView> createState() => Ttw591OtherPlayViewState();
}

class Ttw591OtherPlayViewState extends State<Tw591OtherPlayView> {
  late final VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  VideoPlayStatus? playStatus;

  @override
  void initState() {
    super.initState();

    createController();
  }

  @override
  void dispose() {
    // 移除监听
    videoPlayerController.removeListener(handlePlayerListener);
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (chewieController == null ||
        !videoPlayerController.value.isInitialized) {
      return Container();
    }
    return Chewie(
      controller: chewieController!,
    );
  }

  void createController() async {
    videoPlayerController = VideoPlayerController.network(widget.initUrl);
    await videoPlayerController.initialize();

    final chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: widget.autoPlay,
      allowMuting: true,
      looping: false,
      showControls: false, // 不显示控制面板
    );
    this.chewieController = chewieController;

    // 初始化静音
    chewieController.setVolume(widget.mute ? 0 : 1);
    // 添加监听
    videoPlayerController.addListener(handlePlayerListener);
    // 记录播放器
    widget.playController?.setOtherPlayerController(chewieController);

    setState(() {});
  }

  handlePlayerListener() {
    // 播放时间
    widget.playController?.timeInterval
        ?.call(videoPlayerController.value.position.inSeconds.toDouble());

    // 播放状态
    if (videoPlayerController.value.isPlaying) {
      // 正在播放
      const currentStatus = VideoPlayStatus.play;
      if (playStatus != currentStatus) {
        playStatus = currentStatus;
        widget.playController?.updateStatus?.call(currentStatus);
      }
    } else {
      // 没有在播放
      bool isFinished = videoPlayerController.value.position >=
          videoPlayerController.value.duration;
      final currentStatus =
          isFinished ? VideoPlayStatus.finish : VideoPlayStatus.pause;
      if (playStatus != currentStatus) {
        playStatus = currentStatus;
        widget.playController?.updateStatus?.call(currentStatus);
      }
    }
  }
}
