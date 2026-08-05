import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/mail_message.dart';
import '../providers/mail_provider.dart';
import 'compose_screen.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MailProvider>();
    final account = provider.account;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          InboxTab(),
          StarredTab(),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: '收件箱',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star_rounded),
            label: '星标',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: '设置',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ComposeScreen()),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('写邮件'),
            )
          : null,
    );
  }
}

class InboxTab extends StatefulWidget {
  const InboxTab({super.key});

  @override
  State<InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends State<InboxTab> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<MailProvider>().messages.isEmpty) {
        context.read<MailProvider>().loadMessages();
      }
    });
  }

  Future<void> _refresh() async {
    await context.read<MailProvider>().loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MailProvider>();
    final cs = Theme.of(context).colorScheme;
    final account = provider.account;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Column(
            children: [
              const Text('Cmail'),
              if (account != null)
                Text(
                  account.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refresh,
            ),
          ],
        ),
        if (provider.isLoading && provider.messages.isEmpty)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (provider.messages.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mail_outline, size: 64, color: cs.outline),
                  const SizedBox(height: 16),
                  Text(
                    '收件箱为空',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 88),
            sliver: RefreshIndicator(
              key: _refreshKey,
              onRefresh: _refresh,
              child: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final msg = provider.messages[index];
                    return _MailTile(msg: msg);
                  },
                  childCount: provider.messages.length,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class StarredTab extends StatelessWidget {
  const StarredTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MailProvider>();
    final starred = provider.messages.where((m) => m.isStarred).toList();
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('星标邮件'),
        ),
        if (starred.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outline, size: 64, color: cs.outline),
                  const SizedBox(height: 16),
                  Text(
                    '没有星标邮件',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 88),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _MailTile(msg: starred[index]),
                childCount: starred.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _MailTile extends StatelessWidget {
  final MailMessage msg;

  const _MailTile({required this.msg});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat.Hm().format(date);
    }
    if (date.year == now.year) {
      return DateFormat.MMMd().format(date);
    }
    return DateFormat.yMMMd().format(date);
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    return name.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<MailProvider>();

    return Slidable(
      key: ValueKey(msg.uid),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (_) {
              msg.isStarred = !msg.isStarred;
              provider.notifyListeners();
            },
            backgroundColor: Colors.amber.withOpacity(0.15),
            foregroundColor: Colors.amber,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: Icon(msg.isStarred ? Icons.star_outline : Icons.star_rounded),
          ),
        ],
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetailScreen(message: msg)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: msg.isRead
                      ? cs.surfaceContainerHighest
                      : cs.primaryContainer,
                  foregroundColor: msg.isRead
                      ? cs.onSurfaceVariant
                      : cs.onPrimaryContainer,
                  child: Text(
                    _initials(msg.fromName),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              msg.fromName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: msg.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                fontSize: 15,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(msg.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: msg.isRead ? FontWeight.normal : FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                      if (msg.hasAttachments)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.attach_file,
                                  size: 14, color: cs.primary),
                              const SizedBox(width: 4),
                              Text(
                                '附件',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
