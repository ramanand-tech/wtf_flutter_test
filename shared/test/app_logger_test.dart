import 'package:flutter_test/flutter_test.dart';
import 'package:shared/utils/app_logger.dart';
import 'package:shared/utils/humanize_error.dart';

void main() {
  test('AppLogger keeps last 20 entries with bracket tags', () {
    final logger = AppLogger.instance;
    logger.clear();
    for (var i = 0; i < 25; i++) {
      logger.log(LogTag.chat, 'msg $i');
    }
    expect(logger.logEntries.length, 20);
    expect(logger.logEntries.first.message, contains('msg 5'));
    expect(logger.logEntries.last.tag.bracket, '[CHAT]');
  });

  test('humanizeError maps connection failures', () {
    expect(
      humanizeError('SocketException: Connection refused'),
      contains('token_server'),
    );
  });
}
