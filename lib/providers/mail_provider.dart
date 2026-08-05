import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/email_account.dart';
import '../models/mail_message.dart';
import '../services/mail_service.dart';

class MailProvider extends ChangeNotifier {
  final _secureStorage = const FlutterSecureStorage();
  final _prefs = SharedPreferences.getInstance();
  final MailService _service = MailService();

  EmailAccount? _account;
  List<MailMessage> _messages = [];
  bool _loading = false;
  String? _error;
  bool _isLoggedIn = false;

  EmailAccount? get account => _account;
  List<MailMessage> get messages => _messages;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> loadAccount() async {
    _setLoading(true);
    try {
      final jsonStr = await _secureStorage.read(key: 'cmail_account');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        _account = EmailAccount.fromJson(data);
        _isLoggedIn = true;
        await _connect();
        await loadMessages();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(EmailAccount account) async {
    _setLoading(true);
    _error = null;
    try {
      await _service.connect(account);
      _account = account;
      _isLoggedIn = true;
      await _secureStorage.write(
        key: 'cmail_account',
        value: jsonEncode(account.toJson()),
      );
      await loadMessages();
    } catch (e) {
      _error = '登录失败：$e';
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMessages() async {
    if (!_isLoggedIn) return;
    _setLoading(true);
    try {
      if (!_service.isConnected) {
        await _connect();
      }
      _messages = await _service.fetchInbox(count: 30);
      _error = null;
    } catch (e) {
      _error = '获取邮件失败：$e';
    } finally {
      _setLoading(false);
    }
  }

  Future<MailMessage?> loadDetail(String uid) async {
    try {
      if (!_service.isConnected) await _connect();
      return await _service.fetchMessageDetails(uid);
    } catch (e) {
      _error = '加载邮件详情失败：$e';
      return null;
    }
  }

  Future<void> send({
    required String to,
    required String subject,
    required String body,
    bool isHtml = false,
  }) async {
    _setLoading(true);
    try {
      if (!_service.isConnected) await _connect();
      await _service.sendMessage(
        to: to,
        subject: subject,
        body: body,
        isHtml: isHtml,
      );
      _error = null;
    } catch (e) {
      _error = '发送失败：$e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _service.disconnect();
    await _secureStorage.delete(key: 'cmail_account');
    _account = null;
    _messages = [];
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }

  Future<void> _connect() async {
    if (_account == null) return;
    await _service.connect(_account!);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
