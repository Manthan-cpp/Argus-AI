import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'env_config.dart';

class TelegramService {
  static Future<bool> sendMessage(
    Session session, {
    required String chatId,
    required String message,
  }) async {
    EnvConfig.load();
    final botToken = EnvConfig.get('TELEGRAM_BOT_TOKEN') ?? Platform.environment['TELEGRAM_BOT_TOKEN'];
    if (botToken == null || botToken.isEmpty) {
      session.log('Telegram dispatch simulated (no TELEGRAM_BOT_TOKEN set in .env): Chat $chatId -> $message');
      return true;
    }

    try {
      final client = HttpClient();
      final uri = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;

      final payload = json.encode({
        'chat_id': chatId,
        'text': message,
        'parse_mode': 'Markdown',
      });

      request.write(payload);
      final response = await request.close();
      client.close();

      if (response.statusCode == 200) {
        session.log('Telegram notification sent to $chatId');
        return true;
      } else {
        session.log('Telegram API error status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      session.log('Failed to dispatch Telegram message: $e');
      return false;
    }
  }
}
