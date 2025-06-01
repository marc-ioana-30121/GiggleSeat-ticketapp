// // lib/screens/ticket_detail_screen.dart
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:intl/intl.dart';
// import '../models/ticket_model.dart';
// import '../models/show_model.dart';

// class TicketDetailScreen extends StatelessWidget {
//   final Ticket ticket;
//   final Show show;

//   const TicketDetailScreen({
//     required this.ticket,
//     required this.show,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isPast = show.date.isBefore(DateTime.now());
//     final isUsed = ticket.isUsed;
    
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Ticket Details'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Show details card
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (show.imageUrl.isNotEmpty)
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.network(
//                             show.imageUrl,
//                             height: 180,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       SizedBox(height: 16),
//                       Text(
//                         show.title,
//                         style: Theme.of(context).textTheme.headlineSmall,
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Venue: ${show.venue}',
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(show.date)}',
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         'Time: ${DateFormat('h:mm a').format(show.date)}',
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               SizedBox(height: 24),
              
//               // Ticket status
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: isUsed
//                       ? Colors.green.withOpacity(0.1)
//                       : isPast
//                           ? Colors.red.withOpacity(0.1)
//                           : Colors.blue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       isUsed
//                           ? Icons.check_circle
//                           : isPast
//                               ? Icons.event_busy
//                               : Icons.confirmation_number,
//                       color: isUsed
//                           ? Colors.green
//                           : isPast
//                               ? Colors.red
//                               : Colors.blue,
//                     ),
//                     SizedBox(width: 12),
//                     Text(
//                       isUsed
//                           ? 'Ticket has been used'
//                           : isPast
//                               ? 'Event has already passed'
//                               : 'Valid ticket',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: isUsed
//                             ? Colors.green
//                             : isPast
//                                 ? Colors.red
//                                 : Colors.blue,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               SizedBox(height: 32),
              
//               // QR Code
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       'Your Ticket QR Code',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     SizedBox(height: 16),
//                     Container(
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 10,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: QrImageView(
//                         data: ticket.qrCodeData,
//                         version: QrVersions.auto,
//                         size: 200.0,
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'Present this QR code at the venue',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
              
//               SizedBox(height: 24),
              
//               // Ticket details
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Ticket Information',
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       SizedBox(height: 12),
//                       _buildDetailRow(context, 'Ticket ID', ticket.id.substring(0, 8).toUpperCase()),
//                       _buildDetailRow(context, 'Purchase Date', 
//                           DateFormat('MMM d, yyyy').format(ticket.purchaseDate)),
//                       _buildDetailRow(context, 'Status', 
//                           isUsed ? 'Used' : isPast ? 'Expired' : 'Valid'),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildDetailRow(BuildContext context, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.grey[700],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// lib/screens/ticket_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../models/ticket_model.dart';
import '../models/show_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;
  final Show show;

  const TicketDetailScreen({
    required this.ticket,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = show.date.isBefore(DateTime.now());
    final isUsed = ticket.isUsed;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Your Ticket'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status indicator
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: isUsed
                      ? Colors.green.withOpacity(0.1)
                      : isPast
                          ? Colors.red.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUsed
                          ? Icons.check_circle
                          : isPast
                              ? Icons.event_busy
                              : Icons.confirmation_number,
                      color: isUsed
                          ? Colors.green
                          : isPast
                              ? Colors.red
                              : Colors.blue,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUsed
                              ? 'Ticket has been used'
                              : isPast
                                  ? 'Event has already passed'
                                  : 'Valid ticket',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUsed
                                ? Colors.green
                                : isPast
                                    ? Colors.red
                                    : Colors.blue,
                          ),
                        ),
                        if (!isUsed && !isPast)
                          Text(
                            'Ready to scan at the venue',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Ticket card with tear effect
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Show details part
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (show.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                show.imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          SizedBox(height: 20),
                          
                          // Show title
                          Text(
                            show.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Event details
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            title: 'Date',
                            value: DateFormat('EEEE, MMMM d, yyyy').format(show.date),
                          ),
                          
                          SizedBox(height: 12),
                          
                          _buildDetailRow(
                            icon: Icons.access_time,
                            title: 'Time',
                            value: DateFormat('h:mm a').format(show.date),
                          ),
                          
                          SizedBox(height: 12),
                          
                          _buildDetailRow(
                            icon: Icons.location_on,
                            title: 'Venue',
                            value: show.venue,
                          ),
                        ],
                      ),
                    ),
                    
                    // Tear effect
                    Container(
                      height: 30,
                      child: Stack(
                        children: [
                          // Dotted line
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 15,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    (constraints.maxWidth / 10).floor(),
                                    (index) => Container(
                                      width: 5,
                                      height: 1,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Left circle
                          Positioned(
                            left: -15,
                            top: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Right circle
                          Positioned(
                            right: -15,
                            top: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // QR Code part
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'SCAN QR CODE',
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUsed
                                    ? Colors.grey[300]!
                                    : Colors.grey[200]!,
                                width: 1,
                              ),
                              boxShadow: isUsed
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                QrImageView(
                                  data: ticket.qrCodeData,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  backgroundColor: Colors.white,
                                  foregroundColor: isUsed || isPast
                                      ? Colors.grey[400]!
                                      : Colors.black,
                                ),
                                if (isUsed)
                                  Container(
                                    width: 200,
                                    height: 200,
                                    color: Colors.white.withOpacity(0.6),
                                    child: Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'USED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (isPast && !isUsed)
                                  Container(
                                    width: 200,
                                    height: 200,
                                    color: Colors.white.withOpacity(0.6),
                                    child: Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'EXPIRED',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Ticket #${ticket.id.substring(0, 8).toUpperCase()}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Purchased on ${DateFormat('MMM d, yyyy').format(ticket.purchaseDate)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 30),
              
              // Instructions
              if (!isUsed && !isPast)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue[100]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInstructionItem(
                        context,
                        number: 1,
                        text: 'Arrive at least 15 minutes before the show',
                      ),
                      _buildInstructionItem(
                        context,
                        number: 2,
                        text: 'Have this QR code ready to be scanned at the entrance',
                      ),
                      _buildInstructionItem(
                        context,
                        number: 3,
                        text: 'Enjoy the show!',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInstructionItem(BuildContext context, {required int number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}