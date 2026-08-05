import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/mail_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final provider = context.read<MailProvider>();
    await provider.loadAccount();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Consumer<MailProvider>(
      builder: (context, provider, child) {
        return provider.isLoggedIn ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
