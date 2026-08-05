class EmailProviderPreset {
  final String name;
  final String domain;
  final String imapHost;
  final int imapPort;
  final bool imapSsl;
  final String smtpHost;
  final int smtpPort;
  final bool smtpSsl;
  final bool smtpStartTls;
  final String? note;

  const EmailProviderPreset({
    required this.name,
    required this.domain,
    required this.imapHost,
    required this.imapPort,
    this.imapSsl = true,
    required this.smtpHost,
    required this.smtpPort,
    this.smtpSsl = true,
    this.smtpStartTls = false,
    this.note,
  });
}

class EmailAccount {
  final String email;
  final String password;
  final String displayName;
  final EmailProviderPreset preset;

  const EmailAccount({
    required this.email,
    required this.password,
    required this.displayName,
    required this.preset,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'displayName': displayName,
        'preset': {
          'name': preset.name,
          'domain': preset.domain,
          'imapHost': preset.imapHost,
          'imapPort': preset.imapPort,
          'imapSsl': preset.imapSsl,
          'smtpHost': preset.smtpHost,
          'smtpPort': preset.smtpPort,
          'smtpSsl': preset.smtpSsl,
          'smtpStartTls': preset.smtpStartTls,
        },
      };

  factory EmailAccount.fromJson(Map<String, dynamic> json) {
    final p = json['preset'] as Map<String, dynamic>;
    return EmailAccount(
      email: json['email'] as String,
      password: json['password'] as String,
      displayName: json['displayName'] as String,
      preset: EmailProviderPreset(
        name: p['name'] as String,
        domain: p['domain'] as String,
        imapHost: p['imapHost'] as String,
        imapPort: p['imapPort'] as int,
        imapSsl: p['imapSsl'] as bool? ?? true,
        smtpHost: p['smtpHost'] as String,
        smtpPort: p['smtpPort'] as int,
        smtpSsl: p['smtpSsl'] as bool? ?? true,
        smtpStartTls: p['smtpStartTls'] as bool? ?? false,
      ),
    );
  }
}

final List<EmailProviderPreset> builtInPresets = [
  const EmailProviderPreset(
    name: 'Gmail',
    domain: 'gmail.com',
    imapHost: 'imap.gmail.com',
    imapPort: 993,
    smtpHost: 'smtp.gmail.com',
    smtpPort: 587,
    smtpSsl: false,
    smtpStartTls: true,
    note: 'Gmail 需要开启两步验证并使用应用专用密码',
  ),
  const EmailProviderPreset(
    name: 'Outlook / Hotmail',
    domain: 'outlook.com',
    imapHost: 'outlook.office365.com',
    imapPort: 993,
    smtpHost: 'smtp.office365.com',
    smtpPort: 587,
    smtpSsl: false,
    smtpStartTls: true,
  ),
  const EmailProviderPreset(
    name: 'Yahoo Mail',
    domain: 'yahoo.com',
    imapHost: 'imap.mail.yahoo.com',
    imapPort: 993,
    smtpHost: 'smtp.mail.yahoo.com',
    smtpPort: 587,
    smtpSsl: false,
    smtpStartTls: true,
  ),
  const EmailProviderPreset(
    name: 'QQ 邮箱',
    domain: 'qq.com',
    imapHost: 'imap.qq.com',
    imapPort: 993,
    smtpHost: 'smtp.qq.com',
    smtpPort: 465,
    smtpSsl: true,
    note: 'QQ 邮箱需要使用授权码而非登录密码',
  ),
  const EmailProviderPreset(
    name: '163 网易邮箱',
    domain: '163.com',
    imapHost: 'imap.163.com',
    imapPort: 993,
    smtpHost: 'smtp.163.com',
    smtpPort: 465,
    smtpSsl: true,
    note: '163 邮箱需要使用授权码',
  ),
  const EmailProviderPreset(
    name: 'iCloud Mail',
    domain: 'icloud.com',
    imapHost: 'imap.mail.me.com',
    imapPort: 993,
    smtpHost: 'smtp.mail.me.com',
    smtpPort: 587,
    smtpSsl: false,
    smtpStartTls: true,
  ),
  const EmailProviderPreset(
    name: '其他邮箱',
    domain: '',
    imapHost: '',
    imapPort: 993,
    smtpHost: '',
    smtpPort: 587,
    smtpSsl: false,
    smtpStartTls: true,
  ),
];
