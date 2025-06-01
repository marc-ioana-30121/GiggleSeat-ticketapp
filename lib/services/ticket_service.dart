// lib/services/ticket_service.dart
import 'dart:math' as Math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/show_model.dart';
import '../models/ticket_model.dart';

class TicketService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  Stream<List<Show>> fetchShows() {
    return _db.collection('shows').snapshots().map((snap) =>
        snap.docs.map((doc) => Show.fromDoc(doc)).toList());
  }

  
  Stream<List<Ticket>> fetchUserTickets(String userId) {
    return _db
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        
        .snapshots()
        .map((snap) {
          var tickets = snap.docs.map((doc) => Ticket.fromDoc(doc)).toList();
          // Sort in memory instead
          tickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
          return tickets;
        });
  }

  // Get show details for a ticket
  Future<Show?> getShowForTicket(String showId) async {
    try {
      final doc = await _db.collection('shows').doc(showId).get();
      if (!doc.exists) return null;
      return Show.fromDoc(doc);
    } catch (e) {
      print('Error getting show: $e');
      return null;
    }
  }

  Future<bool> hasTicket(String userId, String showId) async {
    try {
      final snap = await _db
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .where('showId', isEqualTo: showId)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      print('Error checking ticket: $e');
      return false;
    }
  }

  Future<Ticket?> purchaseTicket(String userId, Show show) async {
    try {
      // Use transaction to ensure ticket limit is not exceeded
      return await _db.runTransaction<Ticket?>(
        (transaction) async {
          // Get the current show
          final showDoc = await transaction.get(_db.collection('shows').doc(show.id));
          final showData = showDoc.data() as Map<String, dynamic>? ?? {};
          final ticketLimit = showData['ticketLimit'] ?? 0;
          
          // Get current ticket count
          final ticketsQuery = await _db
              .collection('tickets')
              .where('showId', isEqualTo: show.id)
              .where('isUsed', isEqualTo: false)
              .count()
              .get();
          final ticketCount = ticketsQuery.count;
          
          // Check if ticket limit reached
          if (ticketCount! >= ticketLimit) {
            throw Exception('Show is sold out');
          }
          
          // Create the ticket
          final qr = _uuid.v4();
          final ticketRef = _db.collection('tickets').doc();
          final ticketData = {
            'userId': userId,
            'showId': show.id,
            'purchaseDate': FieldValue.serverTimestamp(),
            'qrCodeData': qr,
            'isUsed': false,
          };
          
          transaction.set(ticketRef, ticketData);
          
          // Return the new ticket
          return Ticket(
            id: ticketRef.id,
            userId: userId,
            showId: show.id,
            purchaseDate: DateTime.now(),
            qrCodeData: qr,
            isUsed: false,
          );
        },
      );
    } catch (e) {
      print('Error purchasing ticket: $e');
      throw e; // Re-throw to handle in UI
    }
  }

  Future<Ticket?> getTicketByQr(String qr) async {
    try {
      final snap = await _db
          .collection('tickets')
          .where('qrCodeData', isEqualTo: qr)
          .limit(1)
          .get();
      
      if (snap.docs.isEmpty) {
        return null;
      }
      
      return Ticket.fromDoc(snap.docs.first);
    } catch (e) {
      return null;
    }
  }

  Future<void> markTicketUsed(String ticketId) async {
    try {
      await _db.collection('tickets').doc(ticketId).update({'isUsed': true});
    } catch (e) {
      throw Exception('Failed to mark ticket as used');
    }
  }

  Future<Ticket?> getTicketByIdPrefix(String idPrefix) async {
    try {
      // Convert to uppercase for case-insensitive comparison
      idPrefix = idPrefix.toUpperCase();
      
      // Get all tickets and filter in memory
      // We can't query by substring in Firestore directly
      final snap = await _db.collection('tickets').get();
      
      for (final doc in snap.docs) {
        // Check if ticket ID starts with the prefix (case insensitive)
        if (doc.id.substring(0, Math.min(8, doc.id.length)).toUpperCase() == idPrefix) {
          return Ticket.fromDoc(doc);
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}