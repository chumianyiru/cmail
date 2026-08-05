import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mail_provider.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _toCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _toCtrl.dispose();
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final to = _toCtrl.text.trim();
    final subject = _subjectCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (to.isEmpty || subject.isEmpty) {
      _showSnack('请填写收件人和主题');
      return;
    }

    await context.read<MailProvider>().send(
          to: to,
          subject: subject,
          body: body,
        );

    final provider = context.read<MailProvider>();
    if (provider.error != null) {
      _showSnack(provider.error!);
    } else {
      if (mounted) Navigator.of(context).pop();
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
    final provider = context.watch<MailProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('写邮件'),
        actions: [
          TextButton.icon(
            onPressed: provider.isLoading ? null : _send,
            icon: provider.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: const Text('发送'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _toCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '收件人',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '主题',
                prefixIcon: Icon(Icons.subject),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _bodyCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: '正文',
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
