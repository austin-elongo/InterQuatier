import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? progress;

  const LoadingIndicator({
    super.key,
    this.message,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (progress != null)
                  CircularProgressIndicator(value: progress)
                else
                  const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${(progress! * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 