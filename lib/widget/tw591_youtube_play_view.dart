import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tw591_video_play/helper/tw591_video_play_helper.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 播放youtube视频
class Tw591YoutubePlayView extends StatefulWidget {
  final String initUrl;
  final bool mute;
  final bool loop;
  final bool autoPlay;
  final Tw591PlayController? playController;

  const Tw591YoutubePlayView({
    Key? key,
    required this.initUrl,
    this.mute = true,
    this.loop = true,
    this.autoPlay = false,
    this.playController,
  }) : super(key: key);

  @override
  State<Tw591YoutubePlayView> createState() => _Tw591YoutubePlayViewState();
}

class _Tw591YoutubePlayViewState extends State<Tw591YoutubePlayView> {
  /// 获取播放网页
  Future<String> getPlayHtml() async {
    /// 网页中内容相关设置查看：https://developers.google.com/youtube/iframe_api_reference?hl=zh-cn#Playback_controls
    String playerHtml = await rootBundle.loadString(
      'packages/tw591_video_play/assets/youtube.html',
    );
    String videoId = Tw591VideoPlayHelper.convertUrlToId(widget.initUrl);
    playerHtml = playerHtml.replaceAll(
      '{videoId}',
      videoId,
    );
    playerHtml = playerHtml.replaceAll(
      '{initMute}',
      widget.mute ? '1' : '0',
    );
    playerHtml = playerHtml.replaceAll(
      '{autoplay}',
      widget.autoPlay ? '1' : '0',
    );
    playerHtml = playerHtml.replaceAll(
      '{loop}',
      widget.loop ? '1' : '0',
    );
    return playerHtml;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        allowsInlineMediaPlayback: true,
        backgroundColor: Colors.black,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        userAgent: Tw591VideoPlayHelper.userAgent,
        zoomEnabled: false,
        gestureNavigationEnabled: true,
        onWebViewCreated: (controller) async {
          widget.playController?.setWebViewController(controller);
          String currentHtml = await getPlayHtml();
          controller.loadHtmlString(currentHtml);
        },
        javascriptChannels: {
          JavascriptChannel(
            name: "Tw591StateChange",
            onMessageReceived: (JavascriptMessage message) {
              String status = message.message;
              // -1 未开始
              // 0 已结束
              // 1 正在播放
              // 2 已暂停
              // 3 正在缓冲
              // 5 已插入视频
              if (status == '1') {
                // 开始播放
                widget.playController?.updatePlayStatus(VideoPlayStatus.play);
              } else if (status == '2') {
                // 暂停
                widget.playController?.updatePlayStatus(VideoPlayStatus.pause);
              } else if (status == '0') {
                // 结束
                widget.playController?.updatePlayStatus(VideoPlayStatus.finish);
              }
            },
          ),
          JavascriptChannel(
            name: "Tw591VideoInfo",
            onMessageReceived: (JavascriptMessage message) {
              debugPrint('test 测试 视频信息=${message.message}');
            },
          ),
          JavascriptChannel(
            name: "Tw591TimeInterval",
            onMessageReceived: (JavascriptMessage message) {
              // 当前时间
              String result = message.message;
              double currentTime = double.tryParse(result) ?? 0.0;
              widget.playController?.updateTimeInterval(currentTime);
            },
          ),
        },
      ),
    );
  }
}
