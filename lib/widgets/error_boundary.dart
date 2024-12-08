import 'package:flutter/material.dart';

class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'An error occurred: ${details.exception}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    };
    return child;
  }
} 