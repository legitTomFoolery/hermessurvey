import 'package:flutter/material.dart';
import 'package:gsecsurvey/screens/admin/widgets/error_view.dart';
import 'package:gsecsurvey/screens/admin/widgets/loading_view.dart';
import 'package:gsecsurvey/services/admin_service.dart';

class SubmissionSummaryScreen extends StatefulWidget {
  const SubmissionSummaryScreen({super.key});

  @override
  State<SubmissionSummaryScreen> createState() =>
      _SubmissionSummaryScreenState();
}

class _SubmissionSummaryScreenState extends State<SubmissionSummaryScreen> {
  List<Map<String, dynamic>> _summaryData = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AdminService.getSubmissionSummary();
      setState(() {
        _summaryData = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading submission data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_errorMessage != null) {
      return ErrorView(
        errorMessage: _errorMessage!,
        onRetry: _loadSummaryData,
      );
    }

    if (_summaryData.isEmpty) {
      return const Center(
        child: Text(
          'No submission data found',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSummaryData,
      child: _buildSubmissionTable(context),
    );
  }

  Widget _buildSubmissionTable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Submission Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Submission Count')),
                ],
                rows: _summaryData.map((data) {
                  return DataRow(
                    cells: [
                      DataCell(Text(data['email'] ?? 'Unknown')),
                      DataCell(Text(data['submissionCount'].toString())),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
