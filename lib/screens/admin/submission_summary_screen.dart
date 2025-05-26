import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
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
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      color: theme.colorScheme.tertiary,
      child: _buildContent(context),
    );
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
      final theme = AdaptiveTheme.of(context).theme;

      return Center(
        child: Text(
          'No submission data found',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 18,
            color: theme.colorScheme.shadow,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSummaryData,
      child: _buildSubmissionTable(context),
    );
  }

  Widget _buildSubmissionTable(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submission Summary',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Theme(
                data: theme.copyWith(
                  dataTableTheme: DataTableThemeData(
                    headingRowColor:
                        MaterialStateProperty.all(theme.colorScheme.surface),
                    dataRowColor:
                        MaterialStateProperty.all(theme.colorScheme.secondary),
                    headingTextStyle: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.shadow,
                    ),
                    dataTextStyle: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        'Email',
                        style: TextStyle(color: theme.colorScheme.shadow),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Submission Count',
                        style: TextStyle(color: theme.colorScheme.shadow),
                      ),
                    ),
                  ],
                  rows: _summaryData.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            data['email'] ?? 'Unknown',
                            style:
                                TextStyle(color: theme.colorScheme.onSecondary),
                          ),
                        ),
                        DataCell(
                          Text(
                            data['submissionCount'].toString(),
                            style:
                                TextStyle(color: theme.colorScheme.onSecondary),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
