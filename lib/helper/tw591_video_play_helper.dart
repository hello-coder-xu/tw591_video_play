import 'package:tw591_video_play/header/tw591_video_play_head.dart';

class Tw591VideoPlayHelper {
  static String get userAgent =>
      'Mozilla/5.0 (Linux; Android 9.0.0; SM-G955U Build/R16NW) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Mobile Safari/537.36';

  /// 获取视频类型
  static VideoPlayType getUrlType(String url) {
    if (url.contains('fb') || url.contains('facebook')) {
      return VideoPlayType.facebook;
    } else if (url.contains('youtu')) {
      return VideoPlayType.youtube;
    }
    return VideoPlayType.other;
  }

  /// 解析youtube播放id
  static String convertUrlToId(String url) {
    if (!url.contains("http") && (url.length == 11)) return url;
    url = url.trim();

    for (var exp in [
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:music\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1) ?? '';
      }
    }
    return '';
  }
}
