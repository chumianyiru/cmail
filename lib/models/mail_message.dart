class MailMessage {
  final String uid;
  final String subject;
  final String fromName;
  final String fromEmail;
  final List<String> to;
  final DateTime date;
  final String preview;
  final String? bodyHtml;
  final String? bodyText;
  final bool hasAttachments;
  bool isRead;
  bool isStarred;

  MailMessage({
    required this.uid,
    required this.subject,
    required this.fromName,
    required this.fromEmail,
    required this.to,
    required this.date,
    required this.preview,
    this.bodyHtml,
    this.bodyText,
    this.hasAttachments = false,
    this.isRead = false,
    this.isStarred = false,
  });
}
