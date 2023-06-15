import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tw591_base_features/features/webview/tw_webview.dart';
import 'package:tw591_video_play/helper/tw591_video_play_helper.dart';
import 'package:tw591_video_play/tw591_play_controller.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 播放youtube视频
class Tw591YoutubePlayView extends StatefulWidget {
  final String initUrl;
  final String blurBackgroundImageUrl;
  final double? videoHeight;
  final bool mute;
  final bool loop;
  final bool autoPlay;
  final Tw591PlayController playController;

  const Tw591YoutubePlayView({
    Key? key,
    required this.initUrl,
    required this.playController,
    this.blurBackgroundImageUrl = '',
    this.videoHeight,
    this.mute = true,
    this.loop = true,
    this.autoPlay = false,
  }) : super(key: key);

  @override
  State<Tw591YoutubePlayView> createState() => _Tw591YoutubePlayViewState();
}

class _Tw591YoutubePlayViewState extends State<Tw591YoutubePlayView> {
  /// 获取播放网页
  Future<String> getPlayHtml() async {
    return '''
<html>
        <head>
            <link rel="stylesheet" href="sample.css">
        </head>
        <body>
            <h1>Flutter Webview</h1>
            <p>This paragraph have styles.</p>
        </body>
        <img src="flutter_logo.png" alt="">
    </html>
''';

    /// 网页中内容相关设置查看：https://developers.google.com/youtube/iframe_api_reference?hl=zh-cn#Playback_controls
    String playerHtml = await rootBundle.loadString(
      'packages/tw591_video_play/assets/youtube.html',
    );
    String videoId = Tw591VideoPlayHelper.convertUrlToId(widget.initUrl);
    playerHtml = playerHtml.replaceAll('{videoId}', videoId);
    playerHtml = playerHtml.replaceAll(
        '{blurBackgroundImageUrl}', widget.blurBackgroundImageUrl);
    playerHtml = playerHtml.replaceAll('{isShowBlur}',
        widget.blurBackgroundImageUrl.isEmpty ? 'none' : 'static');
    String videoHeight =
        widget.videoHeight == null ? '100%' : '${widget.videoHeight}px';
    playerHtml = playerHtml.replaceAll('{videoHeight}', videoHeight);
    playerHtml = playerHtml.replaceAll('{initAutoplay}', '${widget.autoPlay}');
    playerHtml = playerHtml.replaceAll('{initMute}', '${widget.mute ? 1 : 0}');
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
        backgroundColor: Colors.white,
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
              // -1 未开始
              // 0 已结束
              // 1 正在播放
              // 2 已暂停
              // 3 正在缓冲
              // 5 已插入视频
              final intStatus = double.tryParse(status);
              if (intStatus == 1) {
                // 开始播放
                widget.playController.updatePlayStatus(VideoPlayStatus.play);
              } else if (intStatus == 2) {
                // 暂停
                widget.playController.updatePlayStatus(VideoPlayStatus.pause);
              } else if (intStatus == 0) {
                // 结束
                widget.playController.updatePlayStatus(VideoPlayStatus.finish);
              }
            },
          ),
          JavaScriptChannelParams(
            name: "Tw591VideoInfo",
            onMessageReceived: (JavaScriptMessage message) {
              debugPrint('test 测试 视频信息=${message.message}');
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
