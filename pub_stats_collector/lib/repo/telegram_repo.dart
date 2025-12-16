import 'package:firebase_js_interop/extensions.dart';
import 'package:pub_stats_collector/credential/credentials.ops.dart';
import 'package:pub_stats_collector/repo/alert_handler.dart';
import 'package:pub_stats_collector/service/undici_client.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:recase/recase.dart';

class TelegramRepo implements AlertHandler {
  final _client = UndiciClient();

  @override
  Future<void> sendPackageAlert({
    required String package,
    required TelegramAlertConfig config,
    required Map<PackageDataField, Diff> changes,
    required List<String> warnings,
  }) {
    var text = '## [$package](https://pubstats.dev/packages/$package)';
    for (final MapEntry(key: field, value: diff) in changes.entries) {
      text += '\n#### ${field.name.titleCase}\n${diff.text}';
    }

    if (warnings.isNotEmpty) {
      text += '\n#### Warnings';
      for (final warning in warnings) {
        text += '\n\n$warning';
      }
    }

    return _sendMessage(chatId: config.chatId, text: text);
  }

  @override
  Future<void> sendSystemErrorAlert({
    required TelegramAlertConfig config,
    required Object error,
  }) {
    return _sendMessage(chatId: config.chatId, text: '## Error\n$error');
  }

  @override
  Future<void> sendGlobalStatsAlert({
    required TelegramAlertConfig config,
    required GlobalStats stats,
    required Duration duration,
  }) {
    return _sendMessage(
      chatId: config.chatId,
      text:
          '''
## Package Scan Completed

#### Package Count
${stats.packageCount}

#### Most Downloaded Package
${stats.mostDownloadedPackage}

#### Most Liked Package
${stats.mostLikedPackage}

#### Most Depended Package
${stats.mostDependedPackage}

#### Execution Time
${duration.inSeconds} seconds''',
    );
  }

  Future<void> _sendMessage({
    required String chatId,
    required String text,
  }) async {
    await _client.post(
      Uri.parse(
        'https://api.telegram.org/bot${Credentials.telegramBotToken}/sendMessage',
      ),
      body: {'chat_id': chatId, 'text': text, 'parse_mode': 'Markdown'}.toJS,
    );
  }
}
