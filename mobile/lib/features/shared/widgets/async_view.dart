import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';

/// FutureBuilder with the app's loading + error treatment: an ember spinner
/// while loading, and a friendly message + Retry on failure.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.future, required this.builder, this.onRetry});

  final Future<T> future;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.ember, strokeWidth: 3),
          );
        }
        if (snap.hasError || !snap.hasData) {
          final msg = snap.error is ApiException
              ? (snap.error as ApiException).message
              : "Something went wrong.";
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.ink2, height: 1.5)),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    TextButton(onPressed: onRetry, child: const Text('Try again')),
                  ],
                ],
              ),
            ),
          );
        }
        return builder(snap.data as T);
      },
    );
  }
}
