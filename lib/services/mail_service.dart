import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

import '../models/email_account.dart';
import '../models/mail_message.dart';

class MailService {
  MailClient? _client;
  EmailAccount? _account;

  bool get isConnected => _client?.isConnected ?? false;

  Future<void> connect(EmailAccount account) async {
    _account = account;
    await disconnect();

    final incoming = ServerConfig(
      type: ServerType.imap,
      hostname: account.preset.imapHost,
      port: account.preset.imapPort,
      socketType: account.preset.imapSsl ? SocketType.ssl : SocketType.plain,
    );
    final outgoing = ServerConfig(
      type: ServerType.smtp,
      hostname: account.preset.smtpHost,
      port: account.preset.smtpPort,
      socketType: account.preset.smtpSsl
          ? SocketType.ssl
          : (account.preset.smtpStartTls ? SocketType.startTls : SocketType.plain),
    );

    final mailAccount = MailAccount(
      name: account.displayName.isNotEmpty ? account.displayName : account.email,
      userName: account.email,
      email: account.email,
      incomingMailServer: incoming,
      outgoingMailServer: outgoing,
      password: account.password,
    );

    _client = MailClient(mailAccount);
    await _client!.connect();
    await _client!.selectInbox();
  }

  Future<List<MailMessage>> fetchInbox({int count = 30}) async {
    final client = _client;
    if (client == null || !client.isConnected) {
      throw Exception('未连接邮箱');
    }

    final mimeMessages = await client.fetchMessages(count: count);
    return mimeMessages.map(_convertMessage).toList();
  }

  Future<MailMessage> fetchMessageDetails(String uid) async {
    final client = _client;
    if (client == null || !client.isConnected) {
      throw Exception('未连接邮箱');
    }

    final msg = await client.fetchMessage(
      int.tryParse(uid) ?? 0,
      markAsSeen: true,
    );
    return _convertMessage(msg, fetchBody: true);
  }

  Future<void> sendMessage({
    required String to,
    required String subject,
    required String body,
    bool isHtml = false,
  }) async {
    final client = _client;
    if (client == null || !client.isConnected) {
      throw Exception('未连接邮箱');
    }

    final from = _account!.displayName.isNotEmpty
        ? MailAddress(_account!.displayName, _account!.email)
        : MailAddress(_account!.email, _account!.email);
    final message = MessageBuilder.buildSimpleMessage(
      from,
      [MailAddress(to, to)],
      subject,
      isHtml ? body : null,
      isHtml ? null : body,
    );
    await client.sendMessage(message);
  }

  Future<void> disconnect() async {
    if (_client != null && _client!.isConnected) {
      await _client!.disconnect();
    }
    _client = null;
  }

  MailMessage _convertMessage(MimeMessage msg, {bool fetchBody = false}) {
    final from = msg.from?.isNotEmpty ?? false
        ? msg.from!.first
        : MailAddress('', '');
    final toList = msg.to?.map((a) => a.email).toList() ?? [];
    final subject = msg.decodeSubject() ?? '(无主题)';
    final date = msg.decodeDate() ?? DateTime.now();

    String? bodyText;
    String? bodyHtml;
    if (fetchBody) {
      bodyText = msg.decodeTextPlainPart();
      bodyHtml = msg.decodeTextHtmlPart();
    }

    var preview = bodyText ?? msg.decodeTextPlainPart() ?? '';
    preview = preview.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (preview.length > 160) {
      preview = preview.substring(0, 160);
    }

    return MailMessage(
      uid: msg.sequenceId?.toString() ?? msg.uid?.toString() ?? UniqueKey().toString(),
      subject: subject,
      fromName: from.personalName ?? from.email,
      fromEmail: from.email,
      to: toList,
      date: date,
      preview: preview.isEmpty ? '(无正文)' : preview,
      bodyText: bodyText,
      bodyHtml: bodyHtml,
      hasAttachments: msg.hasAttachments(),
      isRead: msg.isSeen,
      isStarred: msg.isFlagged,
    );
  }
}
