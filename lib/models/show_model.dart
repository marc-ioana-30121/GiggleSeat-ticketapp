// lib/models/show_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Show {
  final String id;
  final String title;
  final DateTime date;
  final String venue;
  final int ticketLimit;
  final String imageUrl;

  Show({
    required this.id,
    required this.title,
    required this.date,
    required this.venue,
    required this.ticketLimit,
    required this.imageUrl,
  });

  factory Show.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Show(
      id: doc.id,
      title: data['title'] ?? '',
      date: data['date'] != null 
          ? (data['date'] as Timestamp).toDate() 
          : DateTime.now(),
      venue: data['venue'] ?? '',
      ticketLimit: data['ticketLimit'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'venue': venue,
      'ticketLimit': ticketLimit,
      'imageUrl': imageUrl,
    };
  }
}