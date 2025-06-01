// lib/services/show_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/show_model.dart';

class ShowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> addShow(Show show) async {
    try {
      final docRef = await _db.collection('shows').add(show.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding show: $e');
      throw 'Failed to add show: $e';
    }
  }

  Stream<List<Show>> getShows() {
    return _db
        .collection('shows')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Show.fromDoc(doc)).toList());
  }

  Future<void> deleteShow(String showId) async {
    try {
      await _db.collection('shows').doc(showId).delete();
    } catch (e) {
      print('Error deleting show: $e');
      throw 'Failed to delete show: $e';
    }
  }
}