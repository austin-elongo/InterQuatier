import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final double size;
  final Color? color;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -size / 2,
          top: -size / 2,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.error,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: size * 0.6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 