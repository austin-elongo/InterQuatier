import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/providers/auth_provider.dart';

final premiumProvider = StreamProvider.autoDispose<bool>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data()?['isPremium'] ?? false);
}); 