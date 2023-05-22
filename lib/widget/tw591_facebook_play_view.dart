import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:tw591_video_play/helper/tw591_video_play_helper.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 播放facebook视频
class Tw591FacebookPlayView extends StatefulWidget {
  final String initUrl;
  final bool mute;
  final bool loop;
  final bool autoPlay;
  final Tw591PlayController? playController;

  const Tw591FacebookPlayView(
      {Key? key,
      required this.initUrl,
      this.mute = true,
      this.loop = true,
      this.autoPlay = false,
      this.playController})
      : super(key: key);

  @override
  State<Tw591FacebookPlayView> createState() => _Tw591FacebookPlayViewState();
}

class _Tw591FacebookPlayViewState extends State<Tw591FacebookPlayView> {
  /// 获取播放网页
  Future<String> getPlayHtml() async {
    /// 网页中内容相关设置查看：https://developers.facebook.com/docs/plugins/embedded-video-player
    String playerHtml = await rootBundle.loadString(
      'packages/tw591_video_play/assets/facebook.html',
    );
    playerHtml = playerHtml.replaceAll('{initUrl}', widget.initUrl);
    playerHtml = playerHtml.replaceAll('{autoplay}', '${widget.autoPlay}');
    playerHtml = playerHtml.replaceAll('{mute}', '${widget.mute}');
    return playerHtml;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
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
              if (status == 'startedPlaying') {
                // 开始播放
                widget.playController?.updateStatus?.call(VideoPlayStatus.play);
              } else if (status == 'paused') {
                // 暂停
                widget.playController?.updateStatus
                    ?.call(VideoPlayStatus.pause);
              } else if (status == 'finishedPlaying') {
                // 结束
                widget.playController?.updateStatus
                    ?.call(VideoPlayStatus.finish);
              }
            },
          ),
          JavascriptChannel(
            name: "Tw591TimeInterval",
            onMessageReceived: (JavascriptMessage message) {
              // 当前时间
              String result = message.message;
              double currentTime = double.tryParse(result) ?? 0.0;
              widget.playController?.timeInterval?.call(currentTime);
            },
          ),
        },
      ),
    );
  }
}
