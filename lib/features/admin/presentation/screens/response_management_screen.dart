import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/features/home/data/models/survey_response_model.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/cards/expandable_response_card.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/common/response_filter_section.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/common/response_filter_widgets.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/common/date_range_picker.dart';
import 'package:gsecsurvey/shared/data/services/firestore_service.dart';
import 'package:gsecsurvey/features/admin/data/services/response_admin_service.dart';
import 'package:gsecsurvey/features/admin/data/services/response_export_service.dart';
import 'package:gsecsurvey/shared/presentation/widgets/common_widgets.dart';
import 'package:gsecsurvey/shared/presentation/widgets/common_dialogs.dart';

class ResponseManagementScreen extends StatefulWidget {
  const ResponseManagementScreen({super.key});

  @override
  State<ResponseManagementScreen> createState() =>
      _ResponseManagementScreenState();
}

class _ResponseManagementScreenState extends State<ResponseManagementScreen> {
  List<SurveyResponse> _responses = [];
  List<SurveyResponse> _filteredResponses = [];
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _expandedResponseId;
  bool _showFloatingButton = true;
  final ScrollController _scrollController = ScrollController();

  // Filter state
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRotation;
  String? _selectedAttending;
  Map<String, List<String>> _rotationAttendingMap = {};
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showFloatingButton) {
          setState(() {
            _showFloatingButton = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showFloatingButton) {
          setState(() {
            _showFloatingButton = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        ResponseAdminService.getAllResponses(),
        FirestoreService.getQuestionsOnce(),
      ]);

      final responses = results[0] as List<SurveyResponse>;
      final questionsSnapshot = results[1] as QuerySnapshot<Question>;
      final questions =
          questionsSnapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        _responses = responses;
        _responses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _questions = questions;
        _extractRotationAttendingMap();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _extractRotationAttendingMap() {
    _rotationAttendingMap.clear();
    final rotationQuestion = _questions.firstWhere(
      (q) => q.id == '200-rotation',
      orElse: () => Question(id: '', name: '', type: '', options: []),
    );

    if (rotationQuestion.rotationDetails != null) {
      _rotationAttendingMap =
          Map<String, List<String>>.from(rotationQuestion.rotationDetails!);
    }
  }

  void _applyFilters() {
    _filteredResponses = _responses.where((response) {
      if (_startDate != null || _endDate != null) {
        final responseTimestamp = response.timestamp;

        if (_startDate != null) {
          final startOfDay =
              DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          if (responseTimestamp.isBefore(startOfDay)) {
            return false;
          }
        }

        if (_endDate != null) {
          final endOfDay = DateTime(
              _endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
          if (responseTimestamp.isAfter(endOfDay)) {
            return false;
          }
        }
      }

      if (_selectedRotation != null && response.rotation != _selectedRotation) {
        return false;
      }

      if (_selectedAttending != null &&
          response.attending != _selectedAttending) {
        return false;
      }

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedRotation = null;
      _selectedAttending = null;
      _applyFilters();
    });
  }

  Future<void> _selectDateRange() async {
    try {
      final result = await DateRangePickerService.showCustomDateRangePicker(
        context: context,
        initialStartDate: _startDate,
        initialEndDate: _endDate,
      );

      if (result != null) {
        setState(() {
          _startDate = result.start;
          _endDate = result.end;
          _applyFilters();
        });
      } else {
        // Clear was selected
        setState(() {
          _startDate = null;
          _endDate = null;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting date range: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onRotationChanged(String? rotation) {
    setState(() {
      _selectedRotation = rotation;
      _selectedAttending = null;
      _applyFilters();
    });
  }

  void _onAttendingChanged(String? attending) {
    setState(() {
      _selectedAttending = attending;
      _applyFilters();
    });
  }

  int get _activeFilterCount {
    int count = 0;
    if (_startDate != null && _endDate != null) count++;
    if (_selectedRotation != null) count++;
    if (_selectedAttending != null) count++;
    return count;
  }

  void _showExportModal() {
    ResponseExportService.showExportModal(
      context: context,
      responseCount: _filteredResponses.length,
      onExport: () => ResponseExportService.exportToExcel(
        context: context,
        responses: _filteredResponses,
        questions: _questions,
      ),
    );
  }

  void _onResponseExpanded(String responseId) {
    setState(() {
      _expandedResponseId = responseId;
    });
  }

  void _onResponseCollapsed() {
    setState(() {
      _expandedResponseId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.tertiary,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : _responses.isEmpty
                ? _buildEmptyState()
                : _buildResponsesList(),
      ),
      floatingActionButton: _responses.isNotEmpty && _showFloatingButton
          ? CommonWidgets.buildFloatingActionButton(
              context: context,
              onPressed: _showExportModal,
              icon: Icons.save_alt,
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    final theme = AdaptiveTheme.of(context).theme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: theme.colorScheme.shadow,
          ),
          const SizedBox(height: 16),
          Text(
            'No survey responses found',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 18,
              color: theme.colorScheme.shadow,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Survey responses will appear here once users submit surveys',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 14,
              color: theme.colorScheme.shadow,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesList() {
    return Column(
      children: [
        ResponseFilterSection(
          filteredCount: _filteredResponses.length,
          totalCount: _responses.length,
          isExpanded: _isFilterExpanded,
          onToggleExpanded: () {
            setState(() {
              _isFilterExpanded = !_isFilterExpanded;
            });
          },
          onClearFilters: _clearFilters,
          activeFilterCount: _activeFilterCount,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CompactDateRangeWidget(
                startDate: _startDate,
                endDate: _endDate,
                onPressed: _selectDateRange,
              ),
              CompactDropdownWidget(
                selectedOption: _selectedRotation,
                hint: 'Rotation',
                options: _rotationAttendingMap.keys.toList()..sort(),
                onChanged: _onRotationChanged,
              ),
              if (_selectedRotation != null &&
                  _rotationAttendingMap[_selectedRotation] != null)
                CompactDropdownWidget(
                  selectedOption: _selectedAttending,
                  hint: 'Attending',
                  options: (_rotationAttendingMap[_selectedRotation!] ?? [])
                    ..sort(),
                  onChanged: _onAttendingChanged,
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _filteredResponses.length,
              itemBuilder: (context, index) {
                final response = _filteredResponses[index];
                return Dismissible(
                  key: Key(response.id),
                  dismissThresholds: _expandedResponseId != null
                      ? const {
                          DismissDirection.startToEnd: 1.0,
                          DismissDirection.endToStart: 1.0
                        }
                      : const {},
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (_expandedResponseId != null) {
                      return false;
                    }
                    return await CommonDialogs.showDeleteConfirmationDialog(
                      context: context,
                      title: 'Delete Response',
                      content:
                          'Are you sure you want to delete the response from ${response.formattedDate}? This action cannot be undone.',
                    );
                  },
                  onDismissed: (direction) async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    try {
                      final success = await ResponseAdminService.deleteResponse(
                          response.id);
                      if (success) {
                        _loadData();
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Response deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Failed to delete response'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Error deleting response: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: ExpandableResponseCard(
                    response: response,
                    questions: _questions,
                    onUpdate: _loadData,
                    isExpanded: _expandedResponseId == response.id,
                    onExpanded: () => _onResponseExpanded(response.id),
                    onCollapsed: _onResponseCollapsed,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
