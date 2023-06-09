import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:tw591_video_play/helper/tw591_video_play_helper.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';

class Tw591ControllerUiView extends StatefulWidget {
  final Tw591PlayController controller;

  const Tw591ControllerUiView({Key? key, required this.controller})
      : super(key: key);

  @override
  State<Tw591ControllerUiView> createState() => _Tw591ControllerUiViewState();
}

class _Tw591ControllerUiViewState extends State<Tw591ControllerUiView> {
  /// 2秒后消失
  int hideSecond = 3;

  int currentSecond = 0;

  Timer? timer;

  bool displayUI = false;

  /// 总播放时长
  double get totalTime => widget.controller.totalTime;

  /// 当前播放时长
  double get currentTime => widget.controller.currentTime;

  /// 滑块的值
  late double sliderValue = currentTime;

  /// 显示控件UI
  void showControllerUi() {
    resetTime();
    if (displayUI) {
      displayUI = false;
      if (mounted) setState(() {});
      return;
    }
    displayUI = true;
    if (mounted) setState(() {});
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSecond >= hideSecond) {
        resetTime();
        displayUI = false;
        if (mounted) setState(() {});
      } else {
        currentSecond += 1;
      }
    });
  }

  /// 重置时间
  void resetTime() {
    currentSecond = 0;
    timer?.cancel();
    timer == null;
  }

  @override
  void dispose() {
    resetTime();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Tw591ControllerUiView oldWidget) {
    super.didUpdateWidget(oldWidget);

    sliderValue = currentTime;
  }

  @override
  Widget build(BuildContext context) {
    if (!displayUI) {
      return GestureDetector(
        onTap: showControllerUi,
        behavior: HitTestBehavior.translucent,
        child: Container(
          alignment: Alignment.center,
        ),
      );
    }
    return GestureDetector(
      onTap: showControllerUi,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
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
      ),
    );
  }

  /// 操作按钮视图
  Widget centerView() {
    VideoPlayStatus? videoPlayStatus = widget.controller.videoPlayStatus;
    switch (videoPlayStatus) {
      case VideoPlayStatus.play:
        return IconButton(
          onPressed: () {
            widget.controller.pause();
          },
          icon: const Icon(
            Icons.pause_circle_filled,
            size: 48,
            color: Colors.white,
          ),
        );
      default:
        return IconButton(
          onPressed: () {
            widget.controller.play();
          },
          icon: const Icon(
            Icons.play_circle_filled,
            size: 48,
            color: Colors.white,
          ),
        );
    }
  }

  /// 底部视图
  Widget bottomView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              bottomTimeView(),
              bottomVolumeView(),
            ],
          ),
          bottomProgressView(),
        ],
      ),
    );
  }

  /// 时间
  Widget bottomTimeView() {
    double totalTime = widget.controller.totalTime;
    int displayNumber = Tw591VideoPlayHelper.getTimeDisplayNumber(totalTime);
    double currentTime = widget.controller.currentTime;
    String timeValue = '${Tw591VideoPlayHelper.getTimeValue(
      currentTime,
      displayNumber: displayNumber,
    )} / ${Tw591VideoPlayHelper.getTimeValue(
      totalTime,
      displayNumber: displayNumber,
    )}';
    return Text(
      timeValue,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.white,
      ),
    );
  }

  /// 声音
  Widget bottomVolumeView() {
    return GestureDetector(
      onTap: () {
        if (widget.controller.isMute) {
          widget.controller.unMute();
        } else {
          widget.controller.mute();
        }
      },
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.bottomRight,
        child: Icon(
          widget.controller.isMute ? Icons.volume_off : Icons.volume_up,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 进度
  Widget bottomProgressView() {
    return SizedBox(
      height: 20,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          // 轨道高度
          trackHeight: 5,
          // 轨道形状，可以自定义
          trackShape: Tw591ControllerUiViewRectangularSliderTrackShape(),
          // 激活的轨道颜色
          activeTrackColor: Colors.blueGrey,
          // 未激活的轨道颜色
          inactiveTrackColor: Colors.black26,
          // 滑块形状
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
          thumbColor: Colors.white,
          // 滑块颜色
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 2),
          overlayColor: Colors.black54,
          // 标签形状，可以自定义
          activeTickMarkColor: Colors.red, // 激活的刻度颜色
        ),
        child: Slider(
          min: 0,
          max: totalTime,
          value: sliderValue,
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
          onChanged: (value) {
            updateSlider(value);
          },
          onChangeEnd: (value) {
            updateSlider(value);
            widget.controller.seekTo(value);
            if (VideoPlayStatus.play != widget.controller.videoPlayStatus) {
              widget.controller.play();
            }
          },
        ),
      ),
    );
  }

  /// 更新滑块
  updateSlider(double value) {
    sliderValue = value;
    setState(() {});
  }
}

class Tw591ControllerUiViewRectangularSliderTrackShape
    extends RectangularSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final value = super.getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    // 消除进度条两端的间距
    return Rect.fromLTWH(
        0, value.top, value.width + value.left * 2, value.height);
  }
}
