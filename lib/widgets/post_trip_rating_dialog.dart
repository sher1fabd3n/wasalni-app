import 'package:flutter/material.dart';
import 'package:users_app/l10n/app_localizations.dart';

class PostTripRatingResult {
  final int stars;
  final String? comment;

  const PostTripRatingResult({
    required this.stars,
    this.comment,
  });
}

/// تقييم الرحلة (1–5 نجوم) مع تعليق اختياري بعد انتهاء الرحلة.
class PostTripRatingDialog extends StatefulWidget {
  final String driverName;

  const PostTripRatingDialog({super.key, required this.driverName});

  @override
  State<PostTripRatingDialog> createState() => _PostTripRatingDialogState();
}

class _PostTripRatingDialogState extends State<PostTripRatingDialog> {
  int _stars = 0;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Widget _starRow() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final n = i + 1;
            final filled = n <= _stars;
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: () => setState(() => _stars = n),
              icon: Icon(
                filled ? Icons.star : Icons.star_border,
                color: filled ? Colors.amber : Colors.grey,
                size: 36,
              ),
            );
          }),
        ),
        if (_stars == 0)
          Text(
            loc.ratingStarsHint,
            style: const TextStyle(color: Colors.black45, fontSize: 12),
          ),
      ],
    );
  }

  void _onSubmit() {
    final loc = AppLocalizations.of(context)!;
    if (_stars < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.ratingPickStarsError)),
      );
      return;
    }
    final text = _commentCtrl.text.trim();
    Navigator.of(context).pop(
      PostTripRatingResult(
        stars: _stars,
        comment: text.isEmpty ? null : text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final name = widget.driverName.trim();
    final subtitle = name.isNotEmpty ? name : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.postTripRatingTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                loc.rateTripLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _starRow(),
              const SizedBox(height: 16),
              TextField(
                controller: _commentCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: loc.optionalCommentHint,
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
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black54,
                        side: const BorderSide(color: Colors.black26),
                      ),
                      child: Text(loc.skipRating),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _onSubmit,
                      child: Text(loc.submitRating),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
