import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:gsecsurvey/features/home/data/models/question.dart';
import 'package:gsecsurvey/features/home/data/models/survey_response.dart';
import 'package:gsecsurvey/features/admin/presentation/widgets/cards/expandable_response_card.dart';
import 'package:gsecsurvey/shared/data/services/firestore_service.dart';
import 'package:gsecsurvey/features/admin/data/services/response_admin_service.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

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
      // Hide floating button when scrolling down (user swipes up)
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
      // Load both responses and questions in parallel
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
        // Sort responses by most recent timestamp first
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

    // Find the rotation question to get the rotation-attending mapping
    final rotationQuestion = _questions.firstWhere(
      (q) => q.id == '2-rotation',
      orElse: () => Question(id: '', name: '', type: '', options: []),
    );

    if (rotationQuestion.rotationDetails != null) {
      _rotationAttendingMap =
          Map<String, List<String>>.from(rotationQuestion.rotationDetails!);
    }
  }

  void _applyFilters() {
    _filteredResponses = _responses.where((response) {
      // Date filter - use actual timestamp instead of user-entered date
      if (_startDate != null || _endDate != null) {
        final responseTimestamp = response.timestamp;

        if (_startDate != null) {
          // Compare only the date part (ignore time)
          final startOfDay =
              DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          if (responseTimestamp.isBefore(startOfDay)) {
            return false;
          }
        }

        if (_endDate != null) {
          // End of the selected day (23:59:59)
          final endOfDay = DateTime(
              _endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
          if (responseTimestamp.isAfter(endOfDay)) {
            return false;
          }
        }
      }

      // Rotation filter
      if (_selectedRotation != null && response.rotation != _selectedRotation) {
        return false;
      }

      // Attending filter
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
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _applyFilters();
      });
    }
  }

  void _onRotationChanged(String? rotation) {
    setState(() {
      _selectedRotation = rotation;
      _selectedAttending = null; // Reset attending when rotation changes
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Survey Responses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Export ${_filteredResponses.length} filtered responses to Excel?'),
            const SizedBox(height: 16),
            const Text(
              'The export will include all response details and survey answers.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _exportToExcel();
            },
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('Generating Excel file...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Create Excel workbook
      final excel = excel_lib.Excel.createExcel();
      final sheet = excel['Survey Responses'];

      // Create headers
      final headers = [
        'Response ID',
        'Timestamp',
        'Date',
        'Rotation',
        'Attending',
      ];

      // Add question headers (excluding standard fields)
      for (final question in _questions) {
        if (!question.id.startsWith('1-date') &&
            !question.id.startsWith('2-rotation') &&
            !question.id.startsWith('3-attending')) {
          headers.add(question.name);
        }
      }

      // Add headers to sheet
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
            excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = headers[i];
        cell.cellStyle = excel_lib.CellStyle(bold: true);
      }

      // Add data rows
      for (int rowIndex = 0; rowIndex < _filteredResponses.length; rowIndex++) {
        final response = _filteredResponses[rowIndex];
        final dataRow = rowIndex + 1;

        // Basic response info
        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: dataRow))
            .value = response.id;
        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 1, rowIndex: dataRow))
            .value = response.formattedDateTime;
        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 2, rowIndex: dataRow))
            .value = response.date;
        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: dataRow))
            .value = response.rotation;
        sheet
            .cell(excel_lib.CellIndex.indexByColumnRow(
                columnIndex: 4, rowIndex: dataRow))
            .value = response.attending;

        // Question answers (excluding standard fields)
        int columnIndex = 5;
        for (final question in _questions) {
          if (!question.id.startsWith('1-date') &&
              !question.id.startsWith('2-rotation') &&
              !question.id.startsWith('3-attending')) {
            final answerValue = response.responses[question.id] ?? '';
            sheet
                .cell(excel_lib.CellIndex.indexByColumnRow(
                    columnIndex: columnIndex, rowIndex: dataRow))
                .value = answerValue;
            columnIndex++;
          }
        }
      }

      // Generate file
      final bytes = excel.encode();
      if (bytes != null) {
        final timestamp =
            DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
        final fileName = 'survey_responses_$timestamp.xlsx';

        // Cross-platform file saving
        if (kIsWeb) {
          // Web: Use FileSaver for direct download
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: Uint8List.fromList(bytes),
            ext: 'xlsx',
            mimeType: MimeType.microsoftExcel,
          );
        } else {
          // Mobile/Desktop: Save to Downloads folder and optionally share
          try {
            Directory? downloadsDir;

            if (Platform.isAndroid) {
              // Android: Use Downloads directory
              downloadsDir = Directory('/storage/emulated/0/Download');
              if (!await downloadsDir.exists()) {
                downloadsDir = await getExternalStorageDirectory();
              }
            } else if (Platform.isIOS) {
              // iOS: Use Documents directory (accessible via Files app)
              downloadsDir = await getApplicationDocumentsDirectory();
            } else {
              // Desktop: Use Downloads directory
              downloadsDir = await getDownloadsDirectory();
            }

            if (downloadsDir != null) {
              final file = File('${downloadsDir.path}/$fileName');
              await file.writeAsBytes(bytes);

              // Show success message with option to share
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Excel file saved to Downloads: $fileName'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Share',
                      textColor: Colors.white,
                      onPressed: () async {
                        try {
                          await Share.shareXFiles(
                            [XFile(file.path)],
                            text: 'Survey Responses Export',
                          );
                        } catch (e) {
                          // Share failed, but file is still saved
                        }
                      },
                    ),
                  ),
                );
              }
            } else {
              // Fallback to FileSaver
              await FileSaver.instance.saveFile(
                name: fileName,
                bytes: Uint8List.fromList(bytes),
                ext: 'xlsx',
                mimeType: MimeType.microsoftExcel,
              );
            }
          } catch (e) {
            // Fallback to FileSaver if directory access fails
            await FileSaver.instance.saveFile(
              name: fileName,
              bytes: Uint8List.fromList(bytes),
              ext: 'xlsx',
              mimeType: MimeType.microsoftExcel,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Excel file saved: $fileName'),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting to Excel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          ? FloatingActionButton(
              onPressed: _showExportModal,
              backgroundColor: theme.colorScheme.primary,
              shape: const CircleBorder(),
              child: Icon(
                Icons.save_alt,
                color: theme.colorScheme.onPrimary,
              ),
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
        // Filter options
        _buildFilterSection(),

        // Responses list
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
                  // Disable swipe when any card is expanded
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
                    // Don't allow dismiss when any card is expanded
                    if (_expandedResponseId != null) {
                      return false;
                    }
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Response'),
                        content: Text(
                          'Are you sure you want to delete the response from ${response.formattedDate}? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
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

  Widget _buildFilterSection() {
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.surface),
        ),
      ),
      child: Column(
        children: [
          // Compact header with filter icon and badge
          InkWell(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Filter icon with badge
                  Stack(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      if (_activeFilterCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_filteredResponses.length}/${_responses.length} responses',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (_activeFilterCount > 0)
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  Icon(
                    _isFilterExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.shadow,
                  ),
                ],
              ),
            ),
          ),

          // Expandable filter controls
          if (_isFilterExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Date range filter
                  _buildDateRangeChip(),

                  // Rotation filter
                  _buildRotationDropdown(),

                  // Attending filter (only show if rotation is selected)
                  if (_selectedRotation != null &&
                      _rotationAttendingMap[_selectedRotation] != null)
                    _buildAttendingDropdown(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateRangeChip() {
    final theme = AdaptiveTheme.of(context).theme;
    final hasDateFilter = _startDate != null && _endDate != null;

    return ActionChip(
      avatar: Icon(
        Icons.date_range,
        size: 18,
        color: hasDateFilter
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.shadow,
      ),
      label: Text(
        hasDateFilter
            ? '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}'
            : 'Date Range',
        style: TextStyle(
          color: hasDateFilter
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.shadow,
          fontSize: 12,
        ),
      ),
      backgroundColor:
          hasDateFilter ? theme.colorScheme.primary : theme.colorScheme.surface,
      onPressed: _selectDateRange,
    );
  }

  Widget _buildRotationDropdown() {
    final theme = AdaptiveTheme.of(context).theme;
    final rotations = _rotationAttendingMap.keys.toList()..sort();

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _selectedRotation != null
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRotation,
          hint: Text(
            'Rotation',
            style: TextStyle(
              color: theme.colorScheme.shadow,
              fontSize: 12,
            ),
          ),
          style: TextStyle(
            color: _selectedRotation != null
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.shadow,
            fontSize: 12,
          ),
          dropdownColor: theme.colorScheme.secondary,
          icon: Icon(
            Icons.arrow_drop_down,
            color: _selectedRotation != null
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.shadow,
            size: 18,
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'All Rotations',
                style: TextStyle(color: theme.colorScheme.onSecondary),
              ),
            ),
            ...rotations.map((rotation) => DropdownMenuItem<String>(
                  value: rotation,
                  child: Text(
                    rotation,
                    style: TextStyle(color: theme.colorScheme.onSecondary),
                  ),
                )),
          ],
          onChanged: _onRotationChanged,
        ),
      ),
    );
  }

  Widget _buildAttendingDropdown() {
    final theme = AdaptiveTheme.of(context).theme;
    final attendingOptions = (_rotationAttendingMap[_selectedRotation!] ?? [])
      ..sort();

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _selectedAttending != null
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAttending,
          hint: Text(
            'Attending',
            style: TextStyle(
              color: theme.colorScheme.shadow,
              fontSize: 12,
            ),
          ),
          style: TextStyle(
            color: _selectedAttending != null
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.shadow,
            fontSize: 12,
          ),
          dropdownColor: theme.colorScheme.secondary,
          icon: Icon(
            Icons.arrow_drop_down,
            color: _selectedAttending != null
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.shadow,
            size: 18,
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'All Attending',
                style: TextStyle(color: theme.colorScheme.onSecondary),
              ),
            ),
            ...attendingOptions.map((attending) => DropdownMenuItem<String>(
                  value: attending,
                  child: Text(
                    attending,
                    style: TextStyle(color: theme.colorScheme.onSecondary),
                  ),
                )),
          ],
          onChanged: _onAttendingChanged,
        ),
      ),
    );
  }
}
