import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:tw591_video_play/tw591_video_play_view.dart';

class PlayDemoPage extends StatefulWidget {
  const PlayDemoPage({Key? key}) : super(key: key);

  @override
  State<PlayDemoPage> createState() => _PlayDemoPageState();
}

class _PlayDemoPageState extends State<PlayDemoPage> {
  /// 播放器控制器
  Tw591PlayController controller = Tw591PlayController();

  /// 最大宽度
  double get maxWidth => MediaQuery.of(context).size.width;

  /// 播放类型
  int selectType = 1;

  /// 类型数据
  List<String> playTypeList = ['youtube', 'facebook', '其他'];

  /// 音量
  double sound = 1.0;

  /// 当前是否静音
  bool mute = false;

  /// 总时间
  double totalTime = 0;

  /// 当前时间
  double currentTime = 0;

  @override
  void initState() {
    super.initState();
    controller.addStatusListener((status) {
      switch (status) {
        case VideoPlayStatus.play:
          debugPrint('test 测试 当前状态 ： 播放');
          controller.getTotalTime().then((value) => totalTime = value);
          break;
        case VideoPlayStatus.pause:
          debugPrint('test 测试 当前状态 ： 暂停');
          break;
        case VideoPlayStatus.finish:
          debugPrint('test 测试 当前状态 ： 结束');
          break;
      }
    });
    controller.addIntervalListener((current) {
      currentTime = current;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          playView(),
          playTypeView(),
          controlBtnView(),
          soundView(),
          resultView(),
        ],
      ),
    );
  }

  /// 视频视图
  Widget playView() {
    String initUrl = '';
    if (selectType == 0) {
      initUrl = 'https://www.youtube.com/watch?v=pmT_DvNzCQI';
    } else if (selectType == 1) {
      initUrl = 'https://fb.watch/kD5Ij9HS2T/';
    } else {
      initUrl = 'https://video.591.com.tw/online/target/hls/union/2023/05/08/pc/1683516699736-859624-476554.m3u8';
    }
    return SizedBox(
      width: 411,
      height: 240,
      child: Tw591VideoPlayView(
        playController: controller,
        initUrl: initUrl,
        mute: mute,
        loop: true,
        autoPlay: true,
      ),
    );
  }

  /// 选择视频类型
  Widget playTypeView() {
    return Container(
      width: maxWidth,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: playTypeList.mapIndexed((index, e) {
          bool select = index == selectType;
          return GestureDetector(
            onTap: () {
              selectType = index;
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: 40,
              width: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: select ? Colors.red : Colors.grey,
              ),
              child: Text(
                e,
                style: TextStyle(
                  fontSize: 16,
                  color: select ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 控制按钮视图
  Widget controlBtnView() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              controller.play();
            },
            icon: const Icon(Icons.play_arrow),
          ),
          IconButton(
            onPressed: () {
              controller.pause();
            },
            icon: const Icon(Icons.pause),
          ),
          IconButton(
            onPressed: () {
              if (mute) {
                mute = false;
                controller.unMute();
              } else {
                mute = true;
                controller.mute();
              }
              setState(() {});
            },
            icon: Icon(mute ? Icons.volume_up : Icons.volume_off),
          ),
        ],
      ),
    );
  }

  /// 声音控制
  Widget soundView() {
    Widget result = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: sound,
              activeColor: mute ? Colors.grey : Colors.blue,
              onChanged: (value) {
                sound = value;
                setState(() {});
                controller.setVolume(value * 100);
              },
            ),
          ),
          Text('${sound * 100 ~/ 1}'),
        ],
      ),
    );

    if (mute) {
      result = IgnorePointer(
        ignoring: mute,
        child: result,
      );
    }
    return result;
  }

  /// 结果视图
  Widget resultView() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '总时间 : $totalTime'),
            TextSpan(text: '\n当前时间 : $currentTime'),
            TextSpan(text: '\n静音状态 : ${mute ? '静音' : '非静音'}'),
          ],
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
