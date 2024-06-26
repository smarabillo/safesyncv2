import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import the dart:async package for Timer

class ReportsHistory extends StatefulWidget {
  @override
  _ReportsHistoryState createState() => _ReportsHistoryState();
}

class _ReportsHistoryState extends State<ReportsHistory> {
  List<Report> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer; // Timer for automatic refresh

  @override
  void initState() {
    super.initState();
    _fetchReports();

    // Set up a timer to automatically refresh reports every minute (60000 milliseconds)
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) => _fetchReports());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final response = await http.get(Uri.parse('https://kayegm.helioho.st/reports.php'));

      if (response.statusCode == 200) {
        List<dynamic> reportsJson = json.decode(response.body);
        setState(() {
          _reports = reportsJson.map((json) => Report.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load reports. Server returned an error.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reports. Please check your internet connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Recent Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black54),),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchReports, // Manual refresh on button press
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // Add some space between the header and the list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : _reports.isEmpty
                          ? const Center(
                              child: Text(
                                'No reports available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _reports.length,
                              itemBuilder: (context, index) {
                                Report report = _reports[index];
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      report.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _formatDate(report.date),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReportDetails(report: report),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${_getMonth(dateTime.month)} ${dateTime.day}, ${dateTime.year}';
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}

class Report {
  final String title;
  final int id;
  final String description;
  final String date;

  Report({
    required this.title,
    required this.id,
    required this.description,
    required this.date,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      title: json['type_of_emergency'] ?? 'No title',
      id: json['report_id'] ?? 0,
      description: json['description'] ?? 'No description',
      date: json['date_time'] ?? '',
    );
  }
}

class ReportDetails extends StatelessWidget {
  final Report report;

  ReportDetails({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Reported on: ${report.date}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
