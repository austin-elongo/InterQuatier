import 'package:cloud_firestore/cloud_firestore.dart';

enum RelationshipPrivacy {
  public,
  friends,
  private
}

class RelationshipPrivacySettings {
  final String userId;
  final RelationshipPrivacy defaultPrivacy;
  final Map<String, RelationshipPrivacy> specificSettings;
  final bool showInProfile;
  final bool notifyNewEvents;
  final bool allowInvites;

  const RelationshipPrivacySettings({
    required this.userId,
    this.defaultPrivacy = RelationshipPrivacy.friends,
    this.specificSettings = const {},
    this.showInProfile = true,
    this.notifyNewEvents = true,
    this.allowInvites = true,
  });

  factory RelationshipPrivacySettings.defaults() {
    return RelationshipPrivacySettings(userId: '');
  }

  factory RelationshipPrivacySettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RelationshipPrivacySettings(
      userId: doc.id,
      defaultPrivacy: RelationshipPrivacy.values[data['defaultPrivacy'] ?? 1],
      specificSettings: Map<String, RelationshipPrivacy>.from(
        (data['specificSettings'] ?? {}).map(
          (key, value) => MapEntry(key, RelationshipPrivacy.values[value]),
        ),
      ),
      showInProfile: data['showInProfile'] ?? true,
      notifyNewEvents: data['notifyNewEvents'] ?? true,
      allowInvites: data['allowInvites'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'defaultPrivacy': defaultPrivacy.index,
      'specificSettings': specificSettings.map(
        (key, value) => MapEntry(key, value.index),
      ),
      'showInProfile': showInProfile,
      'notifyNewEvents': notifyNewEvents,
      'allowInvites': allowInvites,
    };
  }

  RelationshipPrivacySettings copyWith({
    String? userId,
    RelationshipPrivacy? defaultPrivacy,
    Map<String, RelationshipPrivacy>? specificSettings,
    bool? showInProfile,
    bool? notifyNewEvents,
    bool? allowInvites,
  }) {
    return RelationshipPrivacySettings(
      userId: userId ?? this.userId,
      defaultPrivacy: defaultPrivacy ?? this.defaultPrivacy,
      specificSettings: specificSettings ?? this.specificSettings,
      showInProfile: showInProfile ?? this.showInProfile,
      notifyNewEvents: notifyNewEvents ?? this.notifyNewEvents,
      allowInvites: allowInvites ?? this.allowInvites,
    );
  }
} 