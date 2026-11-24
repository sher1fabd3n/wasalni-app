import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users_app/config/app_config.dart';
import 'package:users_app/l10n/app_localizations.dart';

/// ملخص سياسة الخصوصية داخل التطبيق + فتح النسخة الكاملة على الويب عند ضبط [AppConfig.privacyPolicyUrl].
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.privacyPolicyTitle,
          style: const TextStyle(color: Colors.grey),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
        ),
        actions: [
          if (AppConfig.isPrivacyPolicyUrlConfigured)
            IconButton(
              tooltip: loc.privacyOpenFullPolicyButton,
              icon: const Icon(Icons.open_in_new, color: Colors.grey),
              onPressed: () => _openPrivacyPolicyUrl(),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            loc.privacySummaryIntro,
            style: const TextStyle(color: Colors.black87, height: 1.45),
          ),
          if (AppConfig.isPrivacyPolicyUrlConfigured) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openPrivacyPolicyUrl(),
              icon: const Icon(Icons.open_in_new),
              label: Text(loc.privacyOpenFullPolicyButton),
            ),
          ],
          const SizedBox(height: 20),
          _SectionTitle(loc.privacySectionDataTitle),
          const SizedBox(height: 8),
          Text(
            loc.privacySectionDataBody,
            style: const TextStyle(color: Colors.black54, height: 1.45),
          ),
          const SizedBox(height: 20),
          _SectionTitle(loc.privacySectionLocationTitle),
          const SizedBox(height: 8),
          Text(
            loc.privacySectionLocationBody,
            style: const TextStyle(color: Colors.black54, height: 1.45),
          ),
          const SizedBox(height: 20),
          _SectionTitle(loc.privacySectionThirdPartiesTitle),
          const SizedBox(height: 8),
          Text(
            loc.privacySectionThirdPartiesBody,
            style: const TextStyle(color: Colors.black54, height: 1.45),
          ),
          const SizedBox(height: 20),
          _SectionTitle(loc.privacySectionRetentionTitle),
          const SizedBox(height: 8),
          Text(
            loc.privacySectionRetentionBody,
            style: const TextStyle(color: Colors.black54, height: 1.45),
          ),
          const SizedBox(height: 20),
          _SectionTitle(loc.privacySectionRightsTitle),
          const SizedBox(height: 8),
          Text(
            loc.privacySectionRightsBody,
            style: const TextStyle(color: Colors.black54, height: 1.45),
          ),
          const SizedBox(height: 20),
          _SectionTitle(loc.privacySectionDeleteTitle),
          const SizedBox(height: 8),
          Text(
            loc.privacySectionDeleteBody,
            style: const TextStyle(color: Colors.black54, height: 1.45),
          ),
          const SizedBox(height: 24),
          Text(
            loc.privacyContactFooter(AppConfig.adminEmail),
            style: const TextStyle(color: Colors.black45, height: 1.45),
          ),
          const SizedBox(height: 28),
          if (!AppConfig.isPrivacyPolicyUrlConfigured)
            Text(
              loc.privacyUrlNotConfiguredHint,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
            ),
        ],
      ),
    );
  }
}

Future<void> _openPrivacyPolicyUrl() async {
  final uri = Uri.tryParse(AppConfig.privacyPolicyUrl.trim());
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFD32F2F),
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
