import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef PlayStatusChange = Function(VideoPlayStatus status);

typedef PlayTimeInterval = Function(double current);

class Tw591PlayController {
  WebViewController? _controller;

  // 状态变化
  PlayStatusChange? updateStatus;

  // 定时器(当前播放时间)
  PlayTimeInterval? timeInterval;

  /// 视频类型
  VideoPlayType? videoType;

  /// 设置webView 控制器
  void setWebViewController(WebViewController controller) {
    _controller = controller;
  }

  /// 视频类型
  void setVideoType(VideoPlayType type) {
    videoType = type;
  }

  /// 状态监听
  void addStatusListener(PlayStatusChange updateStatus) {
    this.updateStatus = updateStatus;
  }

  /// 定时监听
  void addIntervalListener(PlayTimeInterval timeInterval) {
    this.timeInterval = timeInterval;
  }

  /// 是否由网页播放
  bool get _playByWebView =>
      videoType == VideoPlayType.youtube || videoType == VideoPlayType.facebook;

  ///  播放
  void play() {
    if (_playByWebView) {
      _controller?.runJavascript('play()');
    }
  }

  ///  暂停
  void pause() {
    if (_playByWebView) {
      _controller?.runJavascript('pause()');
    }
  }

  /// 加载
  void load({String? url}) {
    if (_playByWebView) {
      _controller?.runJavascript('load()');
    }
  }

  /// 当前是否静音
  Future<bool> isMute() async {
    if (_playByWebView) {
      String? result =
          await _controller?.runJavascriptReturningResult('isMuted()');
      return result == '1';
    }
    return false;
  }

  /// 静音
  void mute() {
    if (_playByWebView) {
      _controller?.runJavascript('mute()');
    }
  }

  /// 非静音
  void unMute() {
    if (_playByWebView) {
      _controller?.runJavascript('unMute()');
    }
  }

  /// 设置音量 [0-100]
  void setVolume(double volume) {
    if (videoType == VideoPlayType.youtube) {
      _controller?.runJavascript('setVolume(${volume ~/ 1})');
    } else if (videoType == VideoPlayType.facebook) {
      _controller?.runJavascript('setVolume(${volume / 100})');
    }
  }

  /// 跳过
  void seekTo(Duration position) {
    if (_playByWebView) {
      _controller?.runJavascript('seekTo()');
    }
  }

  /// 获取当前播放时间
  Future<double> getCurrentTime() async {
    if (_playByWebView) {
      String result =
          await _controller?.runJavascriptReturningResult('getCurrentTime()') ??
              '0';
      return double.tryParse(result) ?? 0.0;
    }
    return 0.0;
  }

  /// 获取视频总时长
  Future<double> getTotalTime() async {
    if (_playByWebView) {
      String result =
          await _controller?.runJavascriptReturningResult('getTotalTime()') ??
              '0';
      return double.tryParse(result) ?? 0.0;
    }
    return 0.0;
  }
}
