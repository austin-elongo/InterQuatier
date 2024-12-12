import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interquatier/models/relationship_privacy_settings.dart';
import 'package:interquatier/providers/auth_provider.dart';

final relationshipPrivacyProvider = StateNotifierProvider<RelationshipPrivacyNotifier, AsyncValue<RelationshipPrivacySettings>>((ref) {
  final user = ref.watch(authProvider);
  return RelationshipPrivacyNotifier(user?.uid ?? '');
});

class RelationshipPrivacyNotifier extends StateNotifier<AsyncValue<RelationshipPrivacySettings>> {
  final String userId;
  final _firestore = FirebaseFirestore.instance;

  RelationshipPrivacyNotifier(this.userId) : super(const AsyncValue.loading()) {
    if (userId.isNotEmpty) {
      _loadSettings();
    }
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('relationships')
          .get();

      final settings = doc.exists
          ? RelationshipPrivacySettings.fromFirestore(doc)
          : RelationshipPrivacySettings(userId: userId);

      state = AsyncValue.data(settings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateSettings(RelationshipPrivacySettings settings) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('relationships')
          .set(settings.toFirestore());

      state = AsyncValue.data(settings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updatePrivacyForRelationship(
    String relationshipId,
    RelationshipPrivacy privacy,
  ) async {
    state.whenData((settings) async {
      final updatedSettings = settings.copyWith(
        specificSettings: {
          ...settings.specificSettings,
          relationshipId: privacy,
        },
      );
      await updateSettings(updatedSettings);
    });
  }
} 