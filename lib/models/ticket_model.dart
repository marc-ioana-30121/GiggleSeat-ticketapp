// lib/models/ticket_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String id;
  final String userId;
  final String showId;
  final DateTime purchaseDate;
  final String qrCodeData;
  final bool isUsed;

  Ticket({
    required this.id,
    required this.userId,
    required this.showId,
    required this.purchaseDate,
    required this.qrCodeData,
    this.isUsed = false,
  });

  factory Ticket.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Ticket(
      id: doc.id,
      userId: data['userId'] ?? '',
      showId: data['showId'] ?? '',
      purchaseDate: data['purchaseDate'] != null 
          ? (data['purchaseDate'] as Timestamp).toDate() 
          : DateTime.now(),
      qrCodeData: data['qrCodeData'] ?? '',
      isUsed: data['isUsed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'showId': showId,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'qrCodeData': qrCodeData,
      'isUsed': isUsed,
    };
  }
}