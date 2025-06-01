// // lib/screens/manage_shows_screen.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/show_model.dart';
// import '../services/show_service.dart';
// import 'add_show_screen.dart';

// class ManageShowsScreen extends StatefulWidget {
//   @override
//   _ManageShowsScreenState createState() => _ManageShowsScreenState();
// }

// class _ManageShowsScreenState extends State<ManageShowsScreen> {
//   final ShowService _showService = ShowService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manage Shows'),
//       ),
//       body: StreamBuilder<List<Show>>(
//         stream: _showService.getShows(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Error loading shows: ${snapshot.error}',
//                 style: TextStyle(color: Colors.red),
//               ),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Text('No shows found. Add your first show!'),
//             );
//           }

//           final shows = snapshot.data!;
//           return ListView.builder(
//             itemCount: shows.length,
//             itemBuilder: (context, index) {
//               final show = shows[index];
//               final isUpcoming = show.date.isAfter(DateTime.now());
              
//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: ListTile(
//                   title: Text(show.title),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('${show.venue} • ${DateFormat('yyyy-MM-dd').format(show.date)}'),
//                       Text('Ticket Limit: ${show.ticketLimit}'),
//                       if (!isUpcoming)
//                         Text(
//                           'Past Show',
//                           style: TextStyle(
//                             color: Colors.red,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                     ],
//                   ),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete, color: Colors.red),
//                     onPressed: () => _confirmDelete(context, show),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => AddShowScreen()),
//         ),
//         child: Icon(Icons.add),
//         tooltip: 'Add New Show',
//       ),
//     );
//   }

//   Future<void> _confirmDelete(BuildContext context, Show show) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Show'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('Are you sure you want to delete "${show.title}"?'),
//                 SizedBox(height: 8),
//                 Text(
//                   'This action cannot be undone.',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text(
//                 'Delete',
//                 style: TextStyle(color: Colors.red),
//               ),
//               onPressed: () async {
//                 try {
//                   await _showService.deleteShow(show.id);
//                   Navigator.of(context).pop();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Show deleted successfully')),
//                   );
//                 } catch (e) {
//                   Navigator.of(context).pop();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error: $e')),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }


// lib/screens/manage_shows_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/show_model.dart';
import '../services/show_service.dart';
import 'add_show_screen.dart';

class ManageShowsScreen extends StatefulWidget {
  @override
  _ManageShowsScreenState createState() => _ManageShowsScreenState();
}

class _ManageShowsScreenState extends State<ManageShowsScreen> with SingleTickerProviderStateMixin {
  final ShowService _showService = ShowService();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Shows'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with stats
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comedy Shows',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your upcoming and past comedy events',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Quick stats row
                  StreamBuilder<List<Show>>(
                    stream: _showService.getShows(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      
                      final shows = snapshot.data!;
                      final now = DateTime.now();
                      final upcomingShows = shows.where((show) => show.date.isAfter(now)).length;
                      final pastShows = shows.length - upcomingShows;
                      
                      return Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              context,
                              label: 'Total Shows',
                              value: shows.length.toString(),
                              icon: Icons.calendar_month,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            _buildVerticalDivider(),
                            _buildStatItem(
                              context,
                              label: 'Upcoming',
                              value: upcomingShows.toString(),
                              icon: Icons.event_available,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            _buildVerticalDivider(),
                            _buildStatItem(
                              context,
                              label: 'Past',
                              value: pastShows.toString(),
                              icon: Icons.event_busy,
                              color: Colors.grey[700]!,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Filter/Sort controls (could be expanded in future)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'All Shows',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort,
                          size: 16,
                          color: Colors.grey[800],
                        ),
                        SizedBox(width: 4),
                        Text(
                          'By Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Shows list
            Expanded(
              child: StreamBuilder<List<Show>>(
                stream: _showService.getShows(),
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
                            'Error loading shows',
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.event_busy,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No shows found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first show using the button below',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddShowScreen()),
                            ),
                            icon: Icon(Icons.add),
                            label: Text('Add Show'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final shows = snapshot.data!;
                  final now = DateTime.now();
                  
                  // Group shows into upcoming and past
                  final upcomingShows = shows.where((show) => show.date.isAfter(now)).toList();
                  final pastShows = shows.where((show) => !show.date.isAfter(now)).toList();
                  
                  return ListView(
                    padding: EdgeInsets.only(bottom: 100), // Extra padding for FAB
                    children: [
                      if (upcomingShows.isNotEmpty) ...[
                        _buildSectionHeader(context, 'Upcoming Shows', Colors.green),
                        ...upcomingShows.map((show) => _buildShowItem(context, show, isUpcoming: true)),
                      ],
                      
                      if (pastShows.isNotEmpty) ...[
                        _buildSectionHeader(context, 'Past Shows', Colors.grey[700]!),
                        ...pastShows.map((show) => _buildShowItem(context, show, isUpcoming: false)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddShowScreen()),
        ),
        icon: Icon(Icons.add),
        label: Text('Add Show'),
        elevation: 4,
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildShowItem(BuildContext context, Show show, {required bool isUpcoming}) {
    final formattedDate = DateFormat('E, MMM d, yyyy • h:mm a').format(show.date);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: SizedBox(
          width: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40, // Reduce from 44 to 40
                height: 40, // Reduce from 44 to 40
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    DateFormat('dd').format(show.date),
                    style: TextStyle(
                      fontSize: 15, // Reduce from 16 to 15
                      fontWeight: FontWeight.bold,
                      color: isUpcoming
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              // Remove the SizedBox height completely
              Text(
                DateFormat('MMM').format(show.date),
                style: TextStyle(
                  fontSize: 9, // Reduce from 10 to 9
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        title: Text(
          show.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
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
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
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
                  formattedDate.split('•')[1].trim(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 12),
                Icon(
                  Icons.confirmation_number,
                  size: 14,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4),
                Text(
                  '${show.ticketLimit} tickets',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (!isUpcoming)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Text(
                  'Past Show',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red[700],
            ),
            onPressed: () => _confirmDelete(context, show),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Show show) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: 12),
              Text('Delete Show'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete "${show.title}"?'),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be undone.',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.delete_outline, size: 18),
              label: Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await _showService.deleteShow(show.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Show deleted successfully'),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16),
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      },
    );
  }
}