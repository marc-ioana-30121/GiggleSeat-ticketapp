// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/ticket_model.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _loading = true;
  List<BarChartGroupData> _barGroups = [];
  int _currentYear = DateTime.now().year;
  int _maxTickets = 0;
  Map<String, int> _monthlyData = {};
  
  @override
  void initState() {
    super.initState();
    _fetchTicketData();
  }
  
  Future<void> _fetchTicketData() async {
    try {
      final startOfYear = DateTime(_currentYear, 1, 1);
      final endOfYear = DateTime(_currentYear + 1, 1, 1).subtract(Duration(seconds: 1));
      
      // Get all tickets purchased this year
      final ticketsSnapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('purchaseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .where('purchaseDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfYear))
          .get();
      
      // Initialize monthly data
      _monthlyData = {
        'Jan': 0, 'Feb': 0, 'Mar': 0, 'Apr': 0, 'May': 0, 'Jun': 0, 
        'Jul': 0, 'Aug': 0, 'Sep': 0, 'Oct': 0, 'Nov': 0, 'Dec': 0
      };
      
      // Count tickets by month
      for (final doc in ticketsSnapshot.docs) {
        final data = doc.data();
        final purchaseDate = (data['purchaseDate'] as Timestamp).toDate();
        final month = DateFormat('MMM').format(purchaseDate);
        
        _monthlyData[month] = (_monthlyData[month] ?? 0) + 1;
      }
      
      // Find max for the chart
      _maxTickets = _monthlyData.values.isEmpty ? 10 : _monthlyData.values.reduce((a, b) => a > b ? a : b);
      _maxTickets = (_maxTickets / 5).ceil() * 5; // Round to nearest 5
      if (_maxTickets < 5) _maxTickets = 5;
      
      // Create bar chart data
      _barGroups = [];
      int index = 0;
      _monthlyData.forEach((month, count) {
        _barGroups.add(
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 16,
                borderRadius: BorderRadius.circular(2),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: _maxTickets.toDouble(),
                  color: Colors.grey[200],
                ),
              ),
            ],
          ),
        );
        index++;
      });
      
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Error fetching ticket data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics data'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket Sales Analytics'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales Analytics',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  'Monthly ticket sales statistics for $_currentYear',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Bar chart
          _loading 
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Year selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios, size: 16),
                              onPressed: () {
                                setState(() {
                                  _currentYear--;
                                  _loading = true;
                                });
                                _fetchTicketData();
                              },
                            ),
                            Text(
                              '$_currentYear',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios, size: 16),
                              onPressed: DateTime.now().year == _currentYear 
                                  ? null 
                                  : () {
                                      setState(() {
                                        _currentYear++;
                                        _loading = true;
                                      });
                                      _fetchTicketData();
                                    },
                              color: DateTime.now().year == _currentYear 
                                  ? Colors.grey 
                                  : null,
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Chart
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _maxTickets.toDouble(),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    //tooltipBgColor: Colors.blueGrey,
                                    tooltipPadding: EdgeInsets.all(8),
                                    tooltipMargin: 8,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final month = _monthlyData.keys.elementAt(group.x.toInt());
                                      final count = rod.toY.round();
                                      return BarTooltipItem(
                                        '$month: $count tickets',
                                        TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  // Updated to use new AxisTitles structure
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value < 0 || value >= _monthlyData.length) {
                                          return const SizedBox.shrink();
                                        }
                                        final month = _monthlyData.keys.elementAt(value.toInt());
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            month,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value % (_maxTickets > 20 ? 10 : 5) != 0) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                      reservedSize: 35,
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: _barGroups,
                                gridData: FlGridData(
                                  show: true,
                                  checkToShowHorizontalLine: (value) => 
                                      value % (_maxTickets > 20 ? 10 : 5) == 0,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey[300],
                                      strokeWidth: 1,
                                      dashArray: [5],
                                    );
                                  },
                                  drawVerticalLine: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Summary
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Summary',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12),
                              _buildSummaryItem(
                                'Total tickets sold', 
                                _monthlyData.values.fold(0, (a, b) => a + b).toString(),
                              ),
                              _buildSummaryItem(
                                'Best month', 
                                _getBestMonth(),
                              ),
                              _buildSummaryItem(
                                'Average monthly sales', 
                                (_monthlyData.values.fold(0, (a, b) => a + b) / 12).toStringAsFixed(1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
  
  String _getBestMonth() {
    if (_monthlyData.isEmpty) return 'N/A';
    
    String bestMonth = '';
    int maxCount = 0;
    
    _monthlyData.forEach((month, count) {
      if (count > maxCount) {
        maxCount = count;
        bestMonth = month;
      }
    });
    
    return '$bestMonth ($maxCount tickets)';
  }
  
  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}