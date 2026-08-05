import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/email_account.dart';
import '../providers/mail_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _imapHostCtrl = TextEditingController();
  final _imapPortCtrl = TextEditingController(text: '993');
  final _smtpHostCtrl = TextEditingController();
  final _smtpPortCtrl = TextEditingController(text: '587');

  EmailProviderPreset _selectedPreset = builtInPresets.first;
  bool _obscurePassword = true;
  bool _imapSsl = true;
  bool _smtpSsl = false;
  bool _smtpStartTls = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _imapHostCtrl.dispose();
    _imapPortCtrl.dispose();
    _smtpHostCtrl.dispose();
    _smtpPortCtrl.dispose();
    super.dispose();
  }

  bool get _isOther => _selectedPreset.name == '其他邮箱';

  void _onPresetChanged(EmailProviderPreset? preset) {
    if (preset == null) return;
    setState(() {
      _selectedPreset = preset;
      if (!_isOther) {
        _imapHostCtrl.text = preset.imapHost;
        _imapPortCtrl.text = preset.imapPort.toString();
        _imapSsl = preset.imapSsl;
        _smtpHostCtrl.text = preset.smtpHost;
        _smtpPortCtrl.text = preset.smtpPort.toString();
        _smtpSsl = preset.smtpSsl;
        _smtpStartTls = preset.smtpStartTls;
      }
    });
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('请输入邮箱和密码');
      return;
    }

    if (_isOther) {
      if (_imapHostCtrl.text.trim().isEmpty || _smtpHostCtrl.text.trim().isEmpty) {
        _showSnack('请填写 IMAP/SMTP 服务器地址');
        return;
      }
    }

    final preset = _isOther
        ? EmailProviderPreset(
            name: '其他邮箱',
            domain: email.split('@').last,
            imapHost: _imapHostCtrl.text.trim(),
            imapPort: int.tryParse(_imapPortCtrl.text) ?? 993,
            imapSsl: _imapSsl,
            smtpHost: _smtpHostCtrl.text.trim(),
            smtpPort: int.tryParse(_smtpPortCtrl.text) ?? 587,
            smtpSsl: _smtpSsl,
            smtpStartTls: _smtpStartTls,
          )
        : _selectedPreset;

    final account = EmailAccount(
      email: email,
      password: password,
      displayName: name.isNotEmpty ? name : email.split('@').first,
      preset: preset,
    );

    await context.read<MailProvider>().login(account);

    final provider = context.read<MailProvider>();
    if (provider.error != null) {
      _showSnack(provider.error!);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<MailProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _buildLogo(cs),
                const SizedBox(height: 32),
                Text(
                  '登录邮箱',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '支持 Gmail、Outlook、QQ、163 等主流邮箱',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildProviderChips(cs),
                if (_selectedPreset.note != null) ...[
                  const SizedBox(height: 12),
                  _buildNote(_selectedPreset.note!),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '邮箱地址',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '密码 / 授权码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: '发件人昵称（可选）',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                if (_isOther) ...[
                  const SizedBox(height: 24),
                  _buildCustomServerSection(cs),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _login,
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('登录', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ColorScheme cs) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.email_rounded, size: 48, color: Colors.white),
    );
  }

  Widget _buildProviderChips(ColorScheme cs) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: builtInPresets.map((preset) {
        final selected = _selectedPreset.name == preset.name;
        return ChoiceChip(
          label: Text(preset.name),
          selected: selected,
          onSelected: (_) => _onPresetChanged(preset),
          selectedColor: cs.primaryContainer,
          labelStyle: TextStyle(
            color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: selected ? Colors.transparent : cs.outlineVariant,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNote(String note) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(fontSize: 13, color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomServerSection(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '自定义服务器',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _imapHostCtrl,
                  decoration: const InputDecoration(labelText: 'IMAP 服务器'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _imapPortCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '端口'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(
                label: const Text('SSL'),
                selected: _imapSsl,
                onSelected: (v) => setState(() => _imapSsl = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _smtpHostCtrl,
                  decoration: const InputDecoration(labelText: 'SMTP 服务器'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _smtpPortCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '端口'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              FilterChip(
                label: const Text('SSL'),
                selected: _smtpSsl,
                onSelected: (v) => setState(() {
                  _smtpSsl = v;
                  if (v) _smtpStartTls = false;
                }),
              ),
              FilterChip(
                label: const Text('STARTTLS'),
                selected: _smtpStartTls,
                onSelected: (v) => setState(() {
                  _smtpStartTls = v;
                  if (v) _smtpSsl = false;
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
