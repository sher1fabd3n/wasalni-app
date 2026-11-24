import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/config/app_config.dart';
import 'package:users_app/l10n/app_localizations.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/services/user_login_lookup_service.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController userNameTextEditingController =
      TextEditingController();
  final TextEditingController userPhoneTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();
  final CommonMethods cMethods = CommonMethods();
  bool _isLoading = false;

  void _signUpPressed() {
    signUpFormValidation();
  }

  void signUpFormValidation() {
    final loc = AppLocalizations.of(context)!;
    if (userNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar(loc.validationNameShort, context);
    } else if (userPhoneTextEditingController.text.trim().length < 7) {
      cMethods.displaySnackBar(loc.validationPhone, context);
    } else if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar(loc.validationEmail, context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar(loc.validationPassword, context);
    } else {
      registerNewUser();
    }
  }

  void _dismissLoadingDialog() {
    if (!mounted) return;
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) {
      nav.pop();
    }
  }

  Future<void> registerNewUser() async {
    if (_isLoading) return;

    final loc = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: loc.registeringAccount),
    );

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
          )
          .timeout(const Duration(seconds: 25));

      if (!mounted) return;
      _dismissLoadingDialog();

      final userData = {
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": UserLoginLookupService.normalizePhone(
          userPhoneTextEditingController.text.trim(),
        ),
        "id": credential.user!.uid,
        "blockStatus": "no",
      };

      await FirebaseDatabase.instance
          .ref()
          .child(AppConfig.usersPath)
          .child(credential.user!.uid)
          .set(userData);

      await UserLoginLookupService.indexPhoneForUser(
        phone: userPhoneTextEditingController.text.trim(),
        email: emailTextEditingController.text.trim(),
        uid: credential.user!.uid,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on TimeoutException {
      if (!mounted) return;
      _dismissLoadingDialog();
      cMethods.displaySnackBar(loc.loginRequestTimeout, context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _dismissLoadingDialog();
      String msg = loc.errorSignupGeneric;
      if (e.code == 'email-already-in-use') {
        msg = loc.errorEmailInUse;
      } else if (e.code == 'invalid-email') {
        msg = loc.errorInvalidEmail;
      } else if (e.code == 'weak-password') {
        msg = loc.errorWeakPassword;
      } else if (e.code == 'network-request-failed') {
        msg = loc.errorNetworkFirebase;
      }
      cMethods.displaySnackBar(msg, context);
    } catch (e) {
      if (!mounted) return;
      _dismissLoadingDialog();
      final err = e.toString().toLowerCase();
      if (err.contains('network') ||
          err.contains('connection') ||
          err.contains('socket')) {
        cMethods.displaySnackBar(loc.errorFirebaseEmulatorHint, context);
      } else {
        cMethods.displaySnackBar(
          e.toString().length > 60 ? loc.errorGeneric : e.toString(),
          context,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset(
                "assets/11.jpg",
                height: 140,
                fit: BoxFit.contain,
              ),
              Text(
                loc.signUpTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: loc.userName,
                        labelStyle: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: Color(0xFFD32F2F),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: loc.phone,
                        labelStyle: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: Color(0xFFD32F2F),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: loc.email,
                        labelStyle: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: Color(0xFFD32F2F),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 1.5,
                          ),
                        ),
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
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: loc.password,
                        labelStyle: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: Color(0xFFD32F2F),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 1.5,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUpPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        _isLoading ? loc.signUpInProgress : loc.signUp,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const LoginScreen()),
                  );
                },
                child: Text(
                  loc.haveAccountLogin,
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
    );
  }
}
