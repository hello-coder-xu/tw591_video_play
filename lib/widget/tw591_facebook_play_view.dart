import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tw591_base_features/features/webview/tw_webview.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:tw591_video_play/helper/tw591_video_play_helper.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 播放facebook视频
class Tw591FacebookPlayView extends StatefulWidget {
  final String initUrl;
  final String blurBackgroundImageUrl;
  final bool mute;
  final bool loop;
  final bool autoPlay;
  final Tw591PlayController playController;

  const Tw591FacebookPlayView({
    Key? key,
    required this.initUrl,
    this.blurBackgroundImageUrl = '',
    this.mute = true,
    this.loop = true,
    this.autoPlay = false,
    required this.playController,
  }) : super(key: key);

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
    playerHtml = playerHtml.replaceAll(
        '{blurBackgroundImageUrl}', widget.blurBackgroundImageUrl);
    playerHtml = playerHtml.replaceAll('{isShowBlur}',
        widget.blurBackgroundImageUrl.isEmpty ? 'none' : 'static');
    playerHtml = playerHtml.replaceAll('{initAutoplay}', '${widget.autoPlay}');
    playerHtml = playerHtml.replaceAll('{initMute}', '${widget.mute}');
    playerHtml = playerHtml.replaceAll('{initLoop}', '${widget.loop}');
    return playerHtml;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: TWWebView(
        javascriptMode: JavaScriptMode.unrestricted,
        allowsInlineMediaPlayback: true,
        backgroundColor: Colors.black,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        userAgent: Tw591VideoPlayHelper.userAgent,
        zoomEnabled: false,
        gestureNavigationEnabled: true,
        onWebViewCreated: (controller) async {
          final webViewController = controller.webViewController;
          widget.playController.setWebViewController(webViewController);
          String currentHtml = await getPlayHtml();
          webViewController.loadHtmlString(currentHtml);
        },
        javascriptChannels: {
          JavaScriptChannelParams(
            name: "Tw591StateChange",
            onMessageReceived: (JavaScriptMessage message) {
              String status = message.message;
              if (status == 'startedPlaying') {
                // 开始播放
                widget.playController.updatePlayStatus(VideoPlayStatus.play);
              } else if (status == 'paused') {
                // 暂停
                widget.playController.updatePlayStatus(VideoPlayStatus.pause);
              } else if (status == 'finishedPlaying') {
                // 结束
                widget.playController.updatePlayStatus(VideoPlayStatus.finish);
              }
            },
          ),
          JavaScriptChannelParams(
            name: "Tw591TimeInterval",
            onMessageReceived: (JavaScriptMessage message) {
              // 当前时间
              String result = message.message;
              double currentTime = double.tryParse(result) ?? 0.0;
              widget.playController.updateTimeInterval(currentTime);
            },
          ),
        },
      ),
    );
  }
}
