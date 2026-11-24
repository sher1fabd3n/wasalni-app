import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/sign_screen.dart';
import 'package:users_app/config/app_config.dart';
import 'package:users_app/l10n/app_localizations.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/services/user_login_lookup_service.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController loginIdentifierTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();
  final CommonMethods cMethods = CommonMethods();
  bool _busy = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  void _clearFieldErrors() {
    if (_emailError != null ||
        _passwordError != null ||
        _generalError != null) {
      setState(() {
        _emailError = null;
        _passwordError = null;
        _generalError = null;
      });
    }
  }

  void _dismissLoadingDialog() {
    if (!mounted) return;
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) {
      nav.pop();
    }
  }

  Future<void> _signIn() async {
    if (_busy) return;

    FocusScope.of(context).unfocus();
    final loc = AppLocalizations.of(context)!;
    final identifier = loginIdentifierTextEditingController.text.trim();
    final password = passwordTextEditingController.text.trim();

    String? identifierErr;
    String? passErr;
    if (identifier.isEmpty ||
        !UserLoginLookupService.isValidLoginIdentifier(identifier)) {
      identifierErr = loc.validationLoginIdentifier;
    }
    if (password.length < 6) {
      passErr = loc.validationPassword;
    }

    if (identifierErr != null || passErr != null) {
      setState(() {
        _emailError = identifierErr;
        _passwordError = passErr;
        _generalError = null;
      });
      cMethods.displaySnackBar(identifierErr ?? passErr!, context);
      return;
    }

    if (Firebase.apps.isEmpty) {
      setState(() => _generalError = loc.firebaseInitFailed);
      cMethods.displaySnackBar(loc.firebaseInitFailed, context);
      return;
    }

    setState(() {
      _busy = true;
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => LoadingDialog(messageText: loc.signingIn),
    );

    try {
      final email = await UserLoginLookupService.resolveEmailForLogin(
        identifier,
      ).timeout(const Duration(seconds: 20));

      if (email == null) {
        if (!mounted) return;
        _dismissLoadingDialog();
        final msg = UserLoginLookupService.looksLikePhone(identifier)
            ? loc.loginPhoneNotFound
            : loc.loginUserNotFound;
        setState(() => _generalError = msg);
        cMethods.displaySnackBar(msg, context);
        return;
      }

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
          .timeout(const Duration(seconds: 25));

      if (!mounted) return;
      _dismissLoadingDialog();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on TimeoutException {
      if (!mounted) return;
      _dismissLoadingDialog();
      setState(() => _generalError = loc.loginRequestTimeout);
      cMethods.displaySnackBar(loc.loginRequestTimeout, context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _dismissLoadingDialog();
      String msg = loc.errorSignupGeneric;
      switch (e.code) {
        case 'user-not-found':
          msg = loc.loginUserNotFound;
          break;
        case 'wrong-password':
        case 'invalid-credential':
          msg = loc.loginInvalidCredentials;
          break;
        case 'invalid-email':
          msg = loc.errorInvalidEmail;
          break;
        case 'user-disabled':
          msg = loc.blockedMessage(AppConfig.adminEmail);
          break;
        case 'too-many-requests':
          msg = loc.loginTooManyRequests;
          break;
        case 'network-request-failed':
          msg = loc.errorNetworkFirebase;
          break;
      }
      setState(() => _generalError = msg);
      cMethods.displaySnackBar(msg, context);
    } catch (e) {
      if (!mounted) return;
      _dismissLoadingDialog();
      final msg =
          e.toString().length > 80 ? loc.errorGeneric : e.toString();
      setState(() => _generalError = msg);
      cMethods.displaySnackBar(msg, context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    loginIdentifierTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      errorMaxLines: 2,
      labelStyle: const TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFFD32F2F),
      ),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.black12),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Color(0xFFD32F2F),
          width: 1.5,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Image.asset(
                  'assets/11.jpg',
                  height: 140,
                  fit: BoxFit.contain,
                ),
                Text(
                  loc.loginTitle,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        TextField(
                          controller: loginIdentifierTextEditingController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.email,
                            AutofillHints.telephoneNumber,
                            AutofillHints.username,
                          ],
                          autocorrect: false,
                          enableSuggestions: false,
                          onChanged: (_) => _clearFieldErrors(),
                          decoration: _fieldDecoration(
                            label: loc.loginEmailOrPhone,
                            errorText: _emailError,
                          ),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: passwordTextEditingController,
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          enableSuggestions: false,
                          autocorrect: false,
                          onChanged: (_) => _clearFieldErrors(),
                          onSubmitted: (_) => _signIn(),
                          decoration: _fieldDecoration(
                            label: loc.password,
                            errorText: _passwordError,
                          ),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        if (_generalError != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _generalError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: _signIn,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFFD32F2F).withValues(alpha: 0.75),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _busy
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        loc.signingIn,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    loc.login,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F),
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: _busy
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const SignUpScreen(),
                            ),
                          );
                        },
                  child: Text(
                    loc.noAccountSignUp,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
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
