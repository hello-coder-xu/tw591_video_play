import 'package:flutter/material.dart';
import 'package:tw591_video_play/helper/tw591_video_play_helper.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:tw591_video_play/widget/tw591_facebook_play_view.dart';
import 'package:tw591_video_play/widget/tw591_other_play_view.dart';
import 'package:tw591_video_play/widget/tw591_youtube_play_view.dart';

/// 播放器
class Tw591VideoPlayView extends StatefulWidget {
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
  State<Tw591VideoPlayView> createState() => _Tw591VideoPlayViewState();
}

class _Tw591VideoPlayViewState extends State<Tw591VideoPlayView> {
  late Tw591PlayController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.playController ?? Tw591PlayController();
    widget.playController!.addListener(updateView);
  }

  /// 更新视图
  void updateView() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant Tw591VideoPlayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initUrl != oldWidget.initUrl) {
      print('test 重置了');
      controller.reset();
    }
  }

  @override
  void dispose() {
    print('test 结束了');
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget result = videoPlayView();
        result = Stack(
          children: [
            result,
            Positioned.fill(
              child: Container(
                color: Colors.black38,
              ),
            ),
            Center(
              child: centerView(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: bottomView(),
            ),
          ],
        );
        return result;
      },
    );
  }

  /// 视频播放视图
  Widget videoPlayView() {
    // 设置视频类型
    VideoPlayType type = Tw591VideoPlayHelper.getUrlType(widget.initUrl);
    widget.playController?.videoType = type;
    switch (type) {
      case VideoPlayType.youtube:
        return Tw591YoutubePlayView(
          initUrl: widget.initUrl,
          mute: widget.mute,
          loop: widget.loop,
          autoPlay: widget.autoPlay,
          playController: controller,
        );
      case VideoPlayType.facebook:
        return Tw591FacebookPlayView(
          initUrl: widget.initUrl,
          mute: widget.mute,
          loop: widget.loop,
          autoPlay: widget.autoPlay,
          playController: controller,
        );
      case VideoPlayType.other:
        return Tw591OtherPlayView(
          initUrl: widget.initUrl,
          mute: widget.mute,
          loop: widget.loop,
          autoPlay: widget.autoPlay,
          playController: controller,
        );
    }
  }

  /// 操作按钮视图
  Widget centerView() {
    VideoPlayStatus? videoPlayStatus = controller.videoPlayStatus;
    switch (videoPlayStatus) {
      case VideoPlayStatus.play:
        return IconButton(
          onPressed: () {
            controller.pause();
          },
          icon: const Icon(
            Icons.pause_circle_filled,
            size: 48,
            color: Colors.white,
          ),
        );
      case VideoPlayStatus.pause:
        return IconButton(
          onPressed: () {
            controller.play();
          },
          icon: const Icon(
            Icons.play_circle_filled,
            size: 48,
            color: Colors.white,
          ),
        );
      case VideoPlayStatus.finish:
        return IconButton(
          onPressed: () {
            controller.play();
          },
          icon: const Icon(
            Icons.play_circle_filled,
            size: 48,
            color: Colors.white,
          ),
        );
      default:
        break;
    }
    return Container();
  }

  /// 底部视图
  Widget bottomView() {
    double sliderValue = 0;
    double totalTime = controller.totalTime;

    int displayNumber = Tw591VideoPlayHelper.getTimeDisplayNumber(totalTime);

    double currentTime = controller.currentTime;
    String timeValue = '${Tw591VideoPlayHelper.getTimeValue(
      currentTime,
      displayNumber: displayNumber,
    )} / ${Tw591VideoPlayHelper.getTimeValue(
      totalTime,
      displayNumber: displayNumber,
    )}';
    if (totalTime > 0) {
      sliderValue = currentTime / totalTime;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeValue,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
              const Icon(
                Icons.volume_up,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
          Container(
            height: 24,
            alignment: Alignment.center,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                // 轨道高度
                trackShape: const RectangularSliderTrackShape(),
                // 轨道形状，可以自定义
                activeTrackColor: Colors.blueGrey,
                // 激活的轨道颜色
                inactiveTrackColor: Colors.black26,
                // 未激活的轨道颜色
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 2),
                thumbColor: Colors.white,
                // 滑块颜色
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 2),
                overlayColor: Colors.black54,
                // 标签形状，可以自定义
                activeTickMarkColor: Colors.red, // 激活的刻度颜色
              ),
              child: Slider(
                value: sliderValue,
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                onChanged: (value) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
