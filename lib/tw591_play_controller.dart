import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:tw591_video_play/header/tw591_video_play_head.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef PlayStatusChange = Function(VideoPlayStatus status);

typedef PlayTimeInterval = Function(double current);

class Tw591PlayController extends ChangeNotifier {
  WebViewController? _controller;

  /// other类型的播放控制器
  FijkPlayer? _otherPlayerController;

  // 状态变化
  PlayStatusChange? _updateStatus;

  // 定时器(当前播放时间)
  PlayTimeInterval? _timeInterval;

  /// 视频类型
  VideoPlayType? videoType;

  /// 视频播放状态
  VideoPlayStatus? videoPlayStatus;

  /// 视频播放时间
  double currentTime = 0;

  /// 视频总时长
  double totalTime = 0;

  /// 是否静音
  bool isMute = false;

  /// 设置webView 控制器
  void setWebViewController(WebViewController controller) {
    _controller = controller;
  }

  /// 设置
  void setOtherPlayerController(FijkPlayer controller) {
    _otherPlayerController = controller;
  }

  /// 视频类型
  void setVideoType(VideoPlayType type) {
    videoType = type;
  }

  /// 状态监听
  void addStatusListener(PlayStatusChange updateStatus) {
    _updateStatus = updateStatus;
  }

  /// 定时监听
  void addIntervalListener(PlayTimeInterval timeInterval) {
    _timeInterval = timeInterval;
  }

  /// 是否由网页播放
  bool get _playByWebView =>
      videoType == VideoPlayType.youtube || videoType == VideoPlayType.facebook;

  ///  播放
  void play() {
    if (_playByWebView) {
      _controller?.runJavascript('play()');
    } else {
      _otherPlayerController?.start();
    }
    notifyListeners();
  }

  ///  暂停
  void pause() {
    if (_playByWebView) {
      _controller?.runJavascript('pause()');
    } else {
      _otherPlayerController?.pause();
    }
    notifyListeners();
  }

  // /// 当前是否静音
  // Future<bool> isMute() async {
  //   if (_playByWebView) {
  //     String? result =
  //         await _controller?.runJavascriptReturningResult('isMuted()');
  //     print('test 当前是否静音 result=$result');
  //     return result == '1';
  //   }
  //
  //   return 0 ==
  //       (_otherPlayerController?.videoPlayerController.value.volume ?? 0);
  // }

  /// 静音
  void mute() {
    isMute = true;
    if (_playByWebView) {
      _controller?.runJavascript('mute()');
    } else {
      _otherPlayerController?.setVolume(0);
    }
  }

  /// 非静音
  void unMute() {
    isMute = false;
    if (_playByWebView) {
      _controller?.runJavascript('unMute()');
    } else {
      _otherPlayerController?.setVolume(1);
    }
  }

  /// 设置音量 [0-100]
  void setVolume(double volume) {
    double vol = volume.clamp(0, 100).toDouble();
    if (videoType == VideoPlayType.youtube) {
      _controller?.runJavascript('setVolume(${vol ~/ 1})');
    } else if (videoType == VideoPlayType.facebook) {
      _controller?.runJavascript('setVolume(${vol / 100})');
    } else {
      _otherPlayerController?.setVolume(vol / 100);
    }
  }

  void seekTo(double seconds) {
    if (videoType == null) return;
    switch (videoType!) {
      case VideoPlayType.youtube:
        _controller?.runJavascript('seekTo($seconds, "true")');
        break;
      case VideoPlayType.facebook:
        _controller?.runJavascript('seekTo($seconds)');
        break;
      case VideoPlayType.other:
        _otherPlayerController?.seekTo(seconds.toInt());
        break;
    }
  }

  /// 设置毛玻璃背景
  void blurBgImageUrl(String url) {
    if (_playByWebView) {
      _controller?.runJavascript('blurBgImageUrl($url)');
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
    return (_otherPlayerController?.currentPos.inSeconds ?? 0).toDouble();
  }

  /// 获取视频总时长
  Future<double> getTotalTime() async {
    if (_playByWebView) {
      String result =
          await _controller?.runJavascriptReturningResult('getTotalTime()') ??
              '0';
      return double.tryParse(result) ?? 0.0;
    }
    return (_otherPlayerController?.value.duration.inSeconds ?? 0).toDouble();
  }

  /// 更新播放状态
  void updatePlayStatus(VideoPlayStatus status) {
    videoPlayStatus = status;
    _updateStatus?.call(status);
    if (status == VideoPlayStatus.play) {
      getTotalTime().then((value) => totalTime = value);
    }
    notifyListeners();
  }

  /// 更新当前播放时长
  void updateTimeInterval(double current) {
    currentTime = current;
    _timeInterval?.call(current);
    notifyListeners();
  }

  /// 重置
  void reset() {
    totalTime = 0;
    currentTime = 0;
    videoPlayStatus = null;
    videoType = null;
  }

  @override
  void dispose() {
    _otherPlayerController = null;
    reset();
    super.dispose();
  }
}
