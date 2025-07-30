import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/common/error_view.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/common/loading_view.dart';
import 'package:gsecsurvey/features/admin/data/services/admin_service.dart';
import 'package:gsecsurvey/shared/presentation/widgets/responsive_wrapper.dart';

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

    return ResponsiveWrapper(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Total Users: ${_summaryData.length}',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_summaryData.fold<int>(0, (sum, data) => sum + (data['submissionCount'] as int))} Total Submissions',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Email Address',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Count',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _summaryData.length,
                        itemBuilder: (context, index) {
                          final data = _summaryData[index];
                          final isEven = index % 2 == 0;

                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: isEven
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.surface
                                      .withValues(alpha: 0.3),
                              border: Border(
                                bottom: BorderSide(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        child: Text(
                                          (data['email'] ?? 'U')[0]
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          data['email'] ?? 'Unknown',
                                          style: theme.textTheme.displayLarge
                                              ?.copyWith(
                                            fontSize: 14,
                                            color:
                                                theme.colorScheme.onSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      data['submissionCount'].toString(),
                                      style: theme.textTheme.displayLarge
                                          ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
