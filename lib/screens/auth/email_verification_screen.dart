import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/providers/auth_provider.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  Timer? _timer;
  bool _canResendEmail = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        await ref.read(authProvider.notifier).auth.currentUser?.reload();
        final user = ref.read(authProvider);
        if (user?.emailVerified ?? false) {
          _timer?.cancel();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
        }
      },
    );
  }

  void _startResendCooldown() {
    setState(() {
      _canResendEmail = false;
      _resendCooldown = 60;
    });

    Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_resendCooldown == 0) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _canResendEmail = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _resendCooldown--;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Verify your email',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'ve sent a verification email to ${ref.read(authProvider)?.email}',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _canResendEmail
                  ? () {
                      ref
                          .read(authProvider.notifier)
                          .resendVerificationEmail();
                      _startResendCooldown();
                    }
                  : null,
              icon: const Icon(Icons.send),
              label: Text(_canResendEmail
                  ? 'Resend Email'
                  : 'Resend in $_resendCooldown seconds'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 