import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

import 'package:smart_farm/screens/otp_screen.dart';
import 'package:smart_farm/screens/signin_screen.dart';
import 'package:smart_farm/theme/app_theme.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:smart_farm/widgets/fast_page_route.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.info_outline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade800 : Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _generateOtp() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // Generates random 4-digit string
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final recipientEmail = _emailController.text.trim();
    final otp = _generateOtp();
    
    // User credentials (temporarily hardcoded for prototype testing)
    final String username = 'likhithreddyr13122005@gmail.com';
    final String password = 'hkgn tyse obzd owud'.replaceAll(' ', '');

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Krushi Mithra')
      ..recipients.add(recipientEmail)
      ..subject = 'Your Krushi Mithra Login OTP'
      ..html = """
        <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
          <h2 style="color: #1E3A2B;">Welcome to Krushi Mithra!</h2>
          <p>Please use the following 4-digit code to log into your account:</p>
          <div style="background-color: #F3F6F3; padding: 15px; border-radius: 8px; display: inline-block;">
            <h1 style="margin: 0; color: #8B9467; letter-spacing: 5px;">$otp</h1>
          </div>
          <p>If you did not request this, please ignore this email.</p>
        </div>
      """;

    try {
      await send(message, smtpServer);
      
      if (!mounted) return;
      
      _showMessage('OTP Sent carefully to $recipientEmail! Check your inbox.');
      
      Navigator.of(context).push(
        FastPageRoute(
          page: OtpScreen(email: recipientEmail, generatedOtp: otp),
        ),
      );
    } on MailerException catch (e) {
      print('Message not sent. \n${e.toString()}');
      _showMessage('Failed to send OTP. Please try again later.', isError: true);
    } catch (e) {
      _showMessage('An unexpected error occurred.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Dynamic background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Image.asset('assets/images/logo.png', width: 80, height: 80),
              const SizedBox(height: 16),
              Text(
                'Krushi Mithra',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.headlineMedium?.color),
              ),
              const SizedBox(height: 12),
              Text(
                'Manage your farm with one tap.\nEnter your email to receive a login code.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: (_) => _sendOtp(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(width: 22, height: 22, child: FarmLoader.small())
                            : const Text('Get OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(FastPageRoute(page: const SignInScreen()));
                          },
                          child: Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
