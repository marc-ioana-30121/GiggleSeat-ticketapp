// // lib/screens/user_tickets_screen.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import '../models/ticket_model.dart';
// import '../models/show_model.dart';
// import '../services/ticket_service.dart';
// import 'ticket_detail_screen.dart';

// class UserTicketsScreen extends StatelessWidget {
//   final TicketService _ticketService = TicketService();

//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser!.uid;
    
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Tickets'),
//       ),
//       body: StreamBuilder<List<Ticket>>(
//         stream: _ticketService.fetchUserTickets(userId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
          
//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Error loading tickets: ${snapshot.error}',
//                 style: TextStyle(color: Colors.red),
//               ),
//             );
//           }
          
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.confirmation_number_outlined,
//                     size: 80,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'No tickets purchased yet',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Check out available shows to buy tickets',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text('Browse Shows'),
//                   ),
//                 ],
//               ),
//             );
//           }
          
//           final tickets = snapshot.data!;
          
//           return ListView.builder(
//             itemCount: tickets.length,
//             itemBuilder: (context, index) {
//               final ticket = tickets[index];
              
//               return FutureBuilder<Show?>(
//                 future: _ticketService.getShowForTicket(ticket.showId),
//                 builder: (context, showSnapshot) {
//                   if (!showSnapshot.hasData) {
//                     return Card(
//                       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       child: ListTile(
//                         title: Text('Loading show details...'),
//                         subtitle: Text('Ticket #${ticket.id.substring(0, 8)}'),
//                       ),
//                     );
//                   }
                  
//                   final show = showSnapshot.data!;
//                   final isPast = show.date.isBefore(DateTime.now());
//                   final isUsed = ticket.isUsed;
                  
//                   return Card(
//                     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: ListTile(
//                       leading: Icon(
//                         isUsed 
//                             ? Icons.check_circle
//                             : isPast 
//                                 ? Icons.event_busy 
//                                 : Icons.confirmation_number,
//                         color: isUsed 
//                             ? Colors.green
//                             : isPast
//                                 ? Colors.red
//                                 : Colors.blue,
//                       ),
//                       title: Text(show.title),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('${show.venue} • ${DateFormat('MMM d, yyyy').format(show.date)}'),
//                           SizedBox(height: 4),
//                           Text(
//                             isUsed
//                                 ? 'Ticket used'
//                                 : isPast
//                                     ? 'Event has passed'
//                                     : 'Valid ticket',
//                             style: TextStyle(
//                               color: isUsed
//                                   ? Colors.green
//                                   : isPast
//                                       ? Colors.red
//                                       : Colors.blue,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       trailing: Icon(Icons.chevron_right),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => TicketDetailScreen(
//                               ticket: ticket,
//                               show: show,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


// lib/screens/user_tickets_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/ticket_model.dart';
import '../models/show_model.dart';
import '../services/ticket_service.dart';
import 'ticket_detail_screen.dart';

class UserTicketsScreen extends StatefulWidget {
  @override
  _UserTicketsScreenState createState() => _UserTicketsScreenState();
}

class _UserTicketsScreenState extends State<UserTicketsScreen> with SingleTickerProviderStateMixin {
  final TicketService _ticketService = TicketService();
  String? _selectedFilter = 'All Tickets';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tickets'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Tickets',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Access and manage your comedy show tickets',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Filter chips
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('All Tickets'),
                    SizedBox(width: 12),
                    _buildFilterChip('Upcoming'),
                    SizedBox(width: 12),
                    _buildFilterChip('Past'),
                    SizedBox(width: 12),
                    _buildFilterChip('Used'),
                  ],
                ),
              ),
            ),
            
            // Divider
            Container(
              height: 4,
              color: Colors.grey[100],
            ),
            
            // Tickets list
            Expanded(
              child: StreamBuilder<List<Ticket>>(
                stream: _ticketService.fetchUserTickets(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading tickets',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  
                  final tickets = snapshot.data!;
                  
                  return FutureBuilder<Map<String, Show?>>(
                    future: _fetchShowsForTickets(tickets),
                    builder: (context, showsSnapshot) {
                      if (!showsSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      
                      final shows = showsSnapshot.data!;
                      final now = DateTime.now();
                      
                      // Filter tickets based on selected filter
                      final filteredTickets = tickets.where((ticket) {
                        if (_selectedFilter == 'All Tickets') return true;
                        
                        final show = shows[ticket.showId];
                        if (show == null) return false;
                        
                        if (_selectedFilter == 'Upcoming') {
                          return show.date.isAfter(now) && !ticket.isUsed;
                        } else if (_selectedFilter == 'Past') {
                          return show.date.isBefore(now);
                        } else if (_selectedFilter == 'Used') {
                          return ticket.isUsed;
                        }
                        
                        return true;
                      }).toList();
                      
                      if (filteredTickets.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off,
                                  size: 40,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No ${_selectedFilter?.toLowerCase()} found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try a different filter',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = filteredTickets[index];
                          final show = shows[ticket.showId];
                          
                          if (show == null) {
                            return SizedBox.shrink(); // Skip if show not found
                          }
                          
                          return _buildTicketCard(context, ticket, show);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_number_outlined,
              size: 80,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No tickets yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'You haven\'t purchased any tickets. Browse available shows to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.local_activity),
            label: Text('Browse Shows'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTicketCard(BuildContext context, Ticket ticket, Show show) {
    final isPast = show.date.isBefore(DateTime.now());
    final isUsed = ticket.isUsed;
    final formattedDate = DateFormat('E, MMM d • h:mm a').format(show.date);
    
    // Determine status and colors
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    if (isUsed) {
      statusText = 'Used';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isPast) {
      statusText = 'Expired';
      statusColor = Colors.red;
      statusIcon = Icons.event_busy;
    } else {
      statusText = 'Valid';
      statusColor = Colors.blue;
      statusIcon = Icons.confirmation_number;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TicketDetailScreen(
                  ticket: ticket,
                  show: show,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Top part with show info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Date circle
                    Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isPast || isUsed
                                ? Colors.grey[200]
                                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('dd').format(show.date),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isPast || isUsed
                                        ? Colors.grey[500]
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM').format(show.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isPast || isUsed
                                        ? Colors.grey[500]
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(width: 16),
                    
                    // Show details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            show.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  show.venue,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // View button/arrow
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
              
              // Bottom part with QR code preview and ticket number
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    // Mini QR placeholder
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isUsed || isPast ? Colors.grey[300] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isUsed || isPast ? Colors.grey[400]! : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.qr_code,
                        size: 24,
                        color: isUsed || isPast ? Colors.grey[500] : Colors.black,
                      ),
                    ),
                    
                    SizedBox(width: 16),
                    
                    // Ticket number
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ticket ID',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '#${ticket.id.substring(0, 8).toUpperCase()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    
                    Spacer(),
                    
                    // Status icon
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
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
  
  Future<Map<String, Show?>> _fetchShowsForTickets(List<Ticket> tickets) async {
    final Map<String, Show?> shows = {};
    
    for (final ticket in tickets) {
      if (!shows.containsKey(ticket.showId)) {
        final show = await _ticketService.getShowForTicket(ticket.showId);
        shows[ticket.showId] = show;
      }
    }
    
    return shows;
  }
}