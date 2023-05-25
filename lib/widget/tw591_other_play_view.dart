import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:video_player/video_player.dart';

class Tw591OtherPlayView extends StatefulWidget {
  final String initUrl;
  final String blurBackgroundImageUrl;
  final bool mute;
  final bool loop;
  final bool autoPlay;
  final Tw591PlayController? playController;

  const Tw591OtherPlayView({
    super.key,
    required this.initUrl,
    this.blurBackgroundImageUrl = '',
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
    if (chewieController == null) {
      return Container();
    }
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: _buildBgImageView(),
        ),
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: _buildBgImageBlur(),
        ),
        Chewie(
          controller: chewieController!,
        ),
      ],
    );
  }

  /// 毛玻璃层
  Widget _buildBgImageBlur() {
    if (widget.blurBackgroundImageUrl.isEmpty) return const SizedBox.shrink();
    return RepaintBoundary(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
      ),
    );
  }

  /// 底部背景
  Widget _buildBgImageView() {
    if (widget.blurBackgroundImageUrl.isEmpty) {
      return Container(color: Colors.black);
    }
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: widget.blurBackgroundImageUrl,
    );
  }

  void createController() async {
    videoPlayerController = VideoPlayerController.network(widget.initUrl);
    try {
      await videoPlayerController.initialize();
    } catch (e) {
      // 初始化失败
      return;
    }
    final chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: widget.autoPlay,
      allowMuting: true,
      looping: widget.loop,
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
    widget.playController?.updateTimeInterval(
        videoPlayerController.value.position.inSeconds.toDouble());

    // 播放状态
    if (videoPlayerController.value.isPlaying) {
      // 正在播放
      const currentStatus = VideoPlayStatus.play;
      if (playStatus != currentStatus) {
        playStatus = currentStatus;
        widget.playController?.updatePlayStatus(currentStatus);
      }
    } else {
      // 没有在播放
      bool isFinished = videoPlayerController.value.position >=
          videoPlayerController.value.duration;
      final currentStatus =
          isFinished ? VideoPlayStatus.finish : VideoPlayStatus.pause;
      if (playStatus != currentStatus) {
        playStatus = currentStatus;
        widget.playController?.updatePlayStatus(currentStatus);
      }
    }
  }
}
