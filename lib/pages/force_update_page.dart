import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/version_gate_service.dart';

class ForceUpdatePage extends StatelessWidget {
  final VersionGateResult gate;

  const ForceUpdatePage({super.key, required this.gate});

  Future<void> _openStore() async {
    final url = Platform.isIOS ? gate.iosStoreUrl : gate.androidStoreUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.system_update, color: Colors.amber, size: 62),
                const SizedBox(height: 20),
                Text(
                  gate.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  gate.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 18),
                Text(
                  'Current: ${gate.currentVersion}  •  Min: ${gate.minSupportedVersion}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
                const SizedBox(height: 26),
                FilledButton.icon(
                  onPressed: _openStore,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Update now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
