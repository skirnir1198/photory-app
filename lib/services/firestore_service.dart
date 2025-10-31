import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/milestone.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Milestone>> getMilestones() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('anniversaries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Milestone.fromFirestore(doc))
            .toList());
  }

  Future<void> addMilestone(Milestone milestone) {
    final user = _auth.currentUser;
    if (user == null) {
      return Future.error('User not logged in');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('anniversaries')
        .add(milestone.toFirestore());
  }

  Future<void> updateMilestone(Milestone milestone) {
    final user = _auth.currentUser;
    if (user == null) {
      return Future.error('User not logged in');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('anniversaries')
        .doc(milestone.id)
        .update(milestone.toFirestore());
  }

  Future<void> deleteMilestone(String milestoneId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Future.error('User not logged in');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('anniversaries')
        .doc(milestoneId)
        .delete();
  }
}
