import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String? text;
  final String? audioUrl;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    this.text,
    this.audioUrl,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> data) {
    return Review(
      id: data['id'],
      userId: data['userId'],
      text: data['text'],
      audioUrl: data['audioUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'audioUrl': audioUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 