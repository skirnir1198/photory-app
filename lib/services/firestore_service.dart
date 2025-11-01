import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/milestone.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMilestonesStream(String userId) {
    return _db
        .collection('milestones')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<DocumentReference> addMilestone(String title, DateTime date, {String? imageUrl}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final newMilestone = Milestone(
      id: '', // Firestore will generate this
      title: title,
      date: date,
      imageUrl: imageUrl,
      userId: user.uid,
    );

    return await _db.collection('milestones').add(newMilestone.toJson());
  }

  Future<void> updateMilestone(Milestone milestone) async {
    await _db.collection('milestones').doc(milestone.id).update(milestone.toJson());
  }

  Future<void> deleteMilestone(String milestoneId) async {
    await _db.collection('milestones').doc(milestoneId).delete();
  }
}
