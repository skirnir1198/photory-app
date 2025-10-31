import 'package:cloud_firestore/cloud_firestore.dart';

class Milestone {
  final String? id;
  final String title;
  final DateTime date;
  final String imageUrl;

  Milestone({
    this.id,
    required this.title,
    required this.date,
    required this.imageUrl,
  });

  factory Milestone.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;;
    return Milestone(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
