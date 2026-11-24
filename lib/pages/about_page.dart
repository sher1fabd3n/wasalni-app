import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users_app/config/app_config.dart';
import 'package:users_app/l10n/app_localizations.dart';
import 'package:users_app/pages/privacy_policy_page.dart';

/// شاشة «عن التطبيق» — الحقول المعروضة وما تضعه في [AppConfig]:
/// - [AppConfig.appName]: اسم التطبيق الظاهر للمستخدم.
/// - [AppConfig.developerDisplayName] / [AppConfig.developerPhone] / [AppConfig.developerFacebookUrl]: بطاقة المطوّر (اترك الفيسبوك فارغاً لإخفائه).
/// - [AppConfig.publisherDisplayName]: الجهة المنشورة (اسمك، شركتك، أو فريق المنتج).
/// - [AppConfig.adminEmail]: بريد التواصل والدعم (يُفتح تطبيق البريد عند الضغط).
/// - الإصدار: يُجلب تلقائياً من [pubspec.yaml] عبر `package_info_plus`.
/// - نصوص «الوظيفة» و«نطاق الخدمة»: من ملفات الترجمة (arb) لتعديلها بلغتين.
/// - سياسة الخصوصية: رابط الويب في [AppConfig.privacyPolicyUrl] + صفحة [PrivacyPolicyPage].
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _versionLabel = '…';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _versionLabel = '${info.version}+${info.buildNumber}';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _versionLabel = '—');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final developerFacebookUri = _tryParseHttpUrl(
      AppConfig.developerFacebookUrl.trim(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.aboutPageTitle,
          style: const TextStyle(color: Colors.grey),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Center(
            child: Image.asset('assets/11.jpg', height: 100),
          ),
          const SizedBox(height: 20),
          Text(
            AppConfig.appName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/waslny_contact_card.jpeg',
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'waslny_contact_card.jpeg',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade200, fontSize: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${loc.aboutFieldVersionLabel}: $_versionLabel',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (AppConfig.developerDisplayName.trim().isNotEmpty) ...[
            _AboutCard(
              title: loc.aboutSectionDeveloperTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConfig.developerDisplayName.trim(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (AppConfig.developerPhone.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      loc.aboutFieldDeveloperPhoneLabel,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final digits = AppConfig.developerPhone.replaceAll(
                          RegExp(r'\s'),
                          '',
                        );
                        final uri = Uri(scheme: 'tel', path: digits);
                        await launchUrl(uri);
                      },
                      child: Text(
                        AppConfig.developerPhone.trim(),
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  if (developerFacebookUri != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      loc.aboutFieldDeveloperFacebookLabel,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        await launchUrl(
                          developerFacebookUri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Text(
                        AppConfig.developerFacebookUrl.trim(),
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          _AboutCard(
            title: loc.aboutSectionWhatIsTitle,
            child: Text(
              loc.aboutWhatIsBody,
              style: const TextStyle(color: Colors.black87, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
          _AboutCard(
            title: loc.aboutSectionServiceAreaTitle,
            child: Text(
              loc.aboutServiceAreaBody,
              style: const TextStyle(color: Colors.black87, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
          _AboutCard(
            title: loc.aboutSectionPublisherTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConfig.publisherDisplayName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.aboutFieldSupportEmailLabel,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse('mailto:${AppConfig.adminEmail}');
                    await launchUrl(uri);
                  },
                  child: Text(
                    AppConfig.adminEmail,
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.black12),
            ),
            tileColor: const Color(0xFFF5F5F5),
            leading: const Icon(Icons.policy_outlined, color: Color(0xFFD32F2F)),
            title: Text(
              loc.privacyPolicyTitle,
              style: const TextStyle(color: Colors.black87),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),
          if (AppConfig.isPrivacyPolicyUrlConfigured) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.tryParse(AppConfig.privacyPolicyUrl.trim());
                  if (uri == null) return;
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_new, color: Color(0xFFD32F2F)),
                label: Text(
                  loc.privacyOpenFullPolicyButton,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            loc.aboutDeleteAccountHint,
            style: const TextStyle(color: Colors.black45, fontSize: 13, height: 1.4),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            const Divider(color: Colors.black12),
            const SizedBox(height: 8),
            Text(
              'Crashlytics — وضع التطوير فقط',
              style: TextStyle(color: Colors.orange.shade200, fontSize: 12),
            ),
            TextButton(
              onPressed: () => FirebaseCrashlytics.instance.crash(),
              child: const Text(
                'اختبار تعطّل (يرسل تقريراً لـ Crashlytics)',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Uri? _tryParseHttpUrl(String raw) {
  if (raw.isEmpty) return null;
  final u = Uri.tryParse(raw);
  if (u == null || !u.hasScheme) return null;
  if (u.scheme != 'http' && u.scheme != 'https') return null;
  return u;
}

class _AboutCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _AboutCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD32F2F),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
