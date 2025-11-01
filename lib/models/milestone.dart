import 'package:cloud_firestore/cloud_firestore.dart';

class Milestone {
  final String id;
  final String title;
  final DateTime date;
  final String? imageUrl;
  final String userId;

  Milestone({
    required this.id,
    required this.title,
    required this.date,
    this.imageUrl,
    required this.userId,
  });

  Milestone copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? imageUrl,
    String? userId,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'userId': userId,
    };
  }

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'] ?? '', // This will be overwritten by document ID
      title: json['title'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'] as String?,
      userId: json['userId'] ?? '',
    );
  }
}
