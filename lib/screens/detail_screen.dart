import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/mail_message.dart';
import '../providers/mail_provider.dart';

class DetailScreen extends StatefulWidget {
  final MailMessage message;

  const DetailScreen({super.key, required this.message});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  MailMessage? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await context.read<MailProvider>().loadDetail(widget.message.uid);
    if (mounted) {
      setState(() {
        _detail = result ?? widget.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final msg = _detail ?? widget.message;

    return Scaffold(
      appBar: AppBar(
        title: const Text('邮件详情'),
        actions: [
          IconButton(
            icon: Icon(msg.isStarred ? Icons.star_rounded : Icons.star_outline),
            color: msg.isStarred ? Colors.amber : null,
            onPressed: () {
              setState(() => msg.isStarred = !msg.isStarred);
              context.read<MailProvider>().notifyListeners();
            },
          ),
        ],
      ),
      body: _loading && _detail == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.subject,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: cs.primaryContainer,
                        foregroundColor: cs.onPrimaryContainer,
                        child: Text(
                          msg.fromName.isNotEmpty
                              ? msg.fromName.characters.first.toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.fromName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              msg.fromEmail,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat.yMMMMEEEEd().add_Hm().format(msg.date),
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (msg.to.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '收件人：${msg.to.join(', ')}',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (msg.hasAttachments)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_file, size: 18, color: cs.primary),
                          const SizedBox(width: 6),
                          Text(
                            '此邮件包含附件',
                            style: TextStyle(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    msg.bodyText ?? msg.preview,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
