import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ValueNotifier<bool>(false);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (_, loading, __) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                FilledButton.icon(
                  onPressed: loading
                      ? null
                      : () async {
                          isLoading.value = true;
                          try {
                            await ref.read(authRepositoryProvider).signInWithGoogle();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          } finally {
                            isLoading.value = false;
                          }
                        },
                  icon: const Icon(Icons.login),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'By continuing you agree to our Terms and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }
}


