import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:users_app/l10n/app_localizations.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/services/rider_feedback_service.dart';

class ComplaintsSuggestionsPage extends StatefulWidget {
  const ComplaintsSuggestionsPage({super.key});

  @override
  State<ComplaintsSuggestionsPage> createState() =>
      _ComplaintsSuggestionsPageState();
}

class _ComplaintsSuggestionsPageState extends State<ComplaintsSuggestionsPage> {
  final _messageCtrl = TextEditingController();
  bool _isComplaint = true;
  bool _sending = false;

  static const _minChars = 8;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    final msg = _messageCtrl.text.trim();
    if (msg.length < _minChars) {
      CommonMethods().displaySnackBar(loc.feedbackMessageTooShort, context);
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      CommonMethods().displaySnackBar(loc.errorGeneric, context);
      return;
    }

    setState(() => _sending = true);
    try {
      await RiderFeedbackService.submitGeneralFeedback(
        type: _isComplaint ? 'complaint' : 'suggestion',
        message: msg,
      );
      if (!mounted) return;
      CommonMethods().displaySnackBar(loc.feedbackSuccess, context);
      _messageCtrl.clear();
    } catch (_) {
      if (mounted) {
        CommonMethods().displaySnackBar(loc.feedbackError, context);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          loc.complaintsAndSuggestionsTitle,
          style: const TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            loc.feedbackIntroBlurb,
            style: const TextStyle(color: Colors.black54, height: 1.45),
          ),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment<bool>(
                value: true,
                label: Text(loc.feedbackTypeComplaint),
                icon: const Icon(Icons.report_problem_outlined, size: 18),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text(loc.feedbackTypeSuggestion),
                icon: const Icon(Icons.lightbulb_outline, size: 18),
              ),
            ],
            selected: {_isComplaint},
            onSelectionChanged: (s) {
              setState(() => _isComplaint = s.first);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageCtrl,
            maxLines: 6,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            decoration: InputDecoration(
              hintText: loc.feedbackMessageHint,
              hintStyle: const TextStyle(color: Colors.black38),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFD32F2F),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(loc.feedbackSubmit),
          ),
        ],
      ),
    );
  }
}
