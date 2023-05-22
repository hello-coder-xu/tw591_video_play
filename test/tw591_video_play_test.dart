import 'package:flutter_test/flutter_test.dart';

void main() {
  test('youutbe测试', () {
    // String url = 'https://www.youtube.com/watch?v=FrriWkcyQbI';
    // String url = 'https://www.youtube.com/watch?v=Fx50I525guQ&feature=youtu.be';
    String url = 'https://m.youtube.com/watch?v=5TFhTpgP3Uk';
    if (!url.contains("http") && (url.length == 11)) return url;
    url = url.trim();

    String result = '';
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
        result = match.group(1) ?? '';
      }
    }
    print('test result=$result');
  });
}
