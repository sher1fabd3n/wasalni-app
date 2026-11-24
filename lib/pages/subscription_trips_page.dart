import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:users_app/l10n/app_localizations.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/services/rider_subscription_service.dart';

/// تسجيل طلب اشتراك رحلات — نموذج مخصص (بدون شكاوى/مقترحات).
class SubscriptionTripsPage extends StatefulWidget {
  const SubscriptionTripsPage({super.key});

  @override
  State<SubscriptionTripsPage> createState() => _SubscriptionTripsPageState();
}

class _SubscriptionTripsPageState extends State<SubscriptionTripsPage> {
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();

  bool? _hasWaitTime;
  int _daysPerWeek = 5;
  bool _sending = false;
  bool _submitted = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: Color(0xFFD32F2F)),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
      ),
    );
  }

  bool _validateFullName(AppLocalizations loc) {
    final t = _fullNameCtrl.text.trim();
    final parts =
        t.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (t.length < 8 || parts.length < 3) {
      CommonMethods().displaySnackBar(loc.subscriptionFullNameValidation, context);
      return false;
    }
    return true;
  }

  bool _validatePhone(AppLocalizations loc) {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      CommonMethods().displaySnackBar(loc.subscriptionPhoneValidation, context);
      return false;
    }
    return true;
  }

  bool _validatePlaces(AppLocalizations loc) {
    if (_pickupCtrl.text.trim().length < 3) {
      CommonMethods().displaySnackBar(loc.subscriptionPickupValidation, context);
      return false;
    }
    if (_dropoffCtrl.text.trim().length < 3) {
      CommonMethods().displaySnackBar(loc.subscriptionDropoffValidation, context);
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    if (!_validateFullName(loc)) return;
    if (!_validatePhone(loc)) return;
    if (!_validatePlaces(loc)) return;
    if (_hasWaitTime == null) {
      CommonMethods().displaySnackBar(loc.subscriptionWaitTimeValidation, context);
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      CommonMethods().displaySnackBar(loc.errorGeneric, context);
      return;
    }

    setState(() => _sending = true);
    try {
      await RiderSubscriptionService.submitStructured(
        fullName: _fullNameCtrl.text,
        phone: _phoneCtrl.text,
        pickupAddress: _pickupCtrl.text,
        dropoffAddress: _dropoffCtrl.text,
        hasWaitTime: _hasWaitTime!,
        daysPerWeek: _daysPerWeek,
      );
      if (!mounted) return;
      setState(() => _submitted = true);
    } catch (_) {
      if (!mounted) return;
      CommonMethods().displaySnackBar(loc.subscriptionError, context);
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(loc.subscriptionTripsTitle),
        centerTitle: true,
      ),
      body: _submitted ? _buildThankYou(loc) : _buildForm(loc),
    );
  }

  Widget _buildThankYou(AppLocalizations loc) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 64),
        const SizedBox(height: 20),
        Text(
          loc.subscriptionRegisteredMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          loc.subscriptionInquiriesCaption,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/waslny_contact_card.jpeg',
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'assets/waslny_contact_card.jpeg',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade200, fontSize: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.subscriptionDoneBack),
        ),
      ],
    );
  }

  Widget _buildForm(AppLocalizations loc) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Center(
          child: Image.asset(
            'assets/images/uber_taxi.png',
            height: 72,
            width: 72,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          loc.subscriptionFormIntro,
          style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _fullNameCtrl,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.black87),
          decoration: _dec(loc.subscriptionFullNameLabel),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.black87),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
          ],
          decoration: _dec(loc.subscriptionPhoneLabel),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _pickupCtrl,
          minLines: 1,
          maxLines: 3,
          style: const TextStyle(color: Colors.black87),
          decoration: _dec(loc.subscriptionPickupLabel),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _dropoffCtrl,
          minLines: 1,
          maxLines: 3,
          style: const TextStyle(color: Colors.black87),
          decoration: _dec(loc.subscriptionDropoffLabel),
        ),
        const SizedBox(height: 18),
        Text(
          loc.subscriptionWaitTimeLabel,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Text(loc.subscriptionWaitTimeYes),
                selected: _hasWaitTime == true,
                onSelected: (_) => setState(() => _hasWaitTime = true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: Text(loc.subscriptionWaitTimeNo),
                selected: _hasWaitTime == false,
                onSelected: (_) => setState(() => _hasWaitTime = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          loc.subscriptionDaysPerWeekLabel,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _daysPerWeek,
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              hint: Text(
                loc.subscriptionDaysPerWeekHint,
                style: const TextStyle(color: Colors.black45),
              ),
              items: List.generate(
                7,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(loc.subscriptionDaysPerWeekOption(i + 1)),
                ),
              ),
              onChanged: (v) {
                if (v != null) setState(() => _daysPerWeek = v);
              },
            ),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
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
          label: Text(loc.subscriptionRegisterButton),
        ),
      ],
    );
  }
}
