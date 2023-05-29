import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:fijkplayer/fijkplayer.dart';

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
  FijkPlayer fPlayer = FijkPlayer();

  VideoPlayStatus? playStatus;

  @override
  void initState() {
    super.initState();

    createController();
  }

  @override
  void dispose() {
    // 移除监听
    fPlayer.removeListener(handlePlayerListener);
    // 释放
    fPlayer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        FijkView(
          player: fPlayer,
          panelBuilder: (player, data, context, viewSize, texturePos) {
            // 不显示控制表盘
            return const SizedBox.shrink();
          },
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
    // 播放视频
    await fPlayer.setDataSource(
      widget.initUrl,
      autoPlay: widget.autoPlay,
    );
    // 默认播放器的循环次数是1， 即不循环播放。如果设置循环次数0，表示无限循环
    await fPlayer.setLoop(widget.loop ? 0 : 1);

    // 初始化静音
    fPlayer.setVolume(widget.mute ? 0 : 1);
    // 添加监听
    fPlayer.addListener(handlePlayerListener);
    // 记录播放器
    widget.playController?.setOtherPlayerController(fPlayer);
  }

  handlePlayerListener() {
    // 播放时间
    widget.playController
        ?.updateTimeInterval(fPlayer.currentPos.inSeconds.toDouble());

    VideoPlayStatus? currentStatus = playStatus;
    // 状态说明：https://fplayer.dev/basic/status.html
    switch (fPlayer.value.state) {
      case FijkState.idle: // 闲置状态
        break;
      case FijkState.initialized: // 初始化完成状态
        break;
      case FijkState.asyncPreparing: // 异步准备状态
        break;
      case FijkState.prepared: // 可以随时进行播放
        break;
      case FijkState.started: // 正在播放
        currentStatus = VideoPlayStatus.play;
        break;
      case FijkState.paused: // 播放暂停
        currentStatus = VideoPlayStatus.pause;
        break;
      case FijkState.completed: // 播放完成。 可重新从头开始播放。
        currentStatus = VideoPlayStatus.finish;
        break;
      case FijkState.stopped: // 播放器各种线程占用资源都已经释放。 音频设备关闭。
        break;
      case FijkState.error: // 播放器出现错误
        break;
      case FijkState.end: // 播放器中所有需要手动释放的内存都释放完成。
        break;
    }

    // 播放状态
    if (playStatus != currentStatus && currentStatus != null) {
      playStatus = currentStatus;
      widget.playController?.updatePlayStatus(currentStatus);
    }
  }
}
