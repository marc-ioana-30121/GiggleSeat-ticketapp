// lib/services/qr_service.dart
import '../models/ticket_model.dart';
import 'ticket_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrService {
  final TicketService _ticketService = TicketService();
  final bool _testMode = true; // Set to true for testing, false for production

  Future<Ticket?> validateQr(String code) async {
    try {
      // Try to find ticket by QR code first
      Ticket? ticket = await _ticketService.getTicketByQr(code);
      
      // If not found, try looking up by ticket ID prefix (for manual entry)
      if (ticket == null) {
        ticket = await _ticketService.getTicketByIdPrefix(code);
      }
      
      if (ticket == null) {
        return null;
      }
      
      if (!ticket.isUsed) {
        await _ticketService.markTicketUsed(ticket.id);
        return ticket;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  
  // Create a test ticket for development purposes
  Future<Ticket?> _createTestTicket(String testCode) async {
    try {
      // Check if we have a test show
      final showsCollection = FirebaseFirestore.instance.collection('shows');
      final showsSnapshot = await showsCollection.limit(1).get();
      
      if (showsSnapshot.docs.isEmpty) {
        return null;
      }
      
      // Use the first show as our test show
      final showId = showsSnapshot.docs.first.id;
      
      // First check if a test ticket with this code already exists
      final existingTickets = await FirebaseFirestore.instance
          .collection('tickets')
          .where('qrCodeData', isEqualTo: testCode)
          .limit(1)
          .get();
      
      // If a test ticket exists but is marked as used, create a new one
      if (existingTickets.docs.isNotEmpty) {
        final existingTicket = Ticket.fromDoc(existingTickets.docs.first);
        
        // If not used, return it
        if (!existingTicket.isUsed) {
          return existingTicket;
        }
        
        // Otherwise, create a new one with a modified code
        testCode = '$testCode-${DateTime.now().millisecondsSinceEpoch}';
      }
      
      // Create a new test ticket
      final ticketRef = FirebaseFirestore.instance.collection('tickets').doc();
      
      // Create a test ticket
      final ticket = Ticket(
        id: ticketRef.id,
        userId: 'test-user',
        showId: showId,
        purchaseDate: DateTime.now(),
        qrCodeData: testCode,
        isUsed: false,
      );
      
      // Convert to map and save
      final ticketMap = ticket.toMap();
      
      // Save it to Firestore
      await ticketRef.set(ticketMap);
      
      // Return the ticket
      return ticket;
    } catch (e) {
      return null;
    }
  }
}