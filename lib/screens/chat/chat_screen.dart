import 'package:flutter/material.dart';
import 'package:interquatier/screens/common/coming_soon_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Chat',
      message: 'Chat feature coming soon!',
    );
  }
} 