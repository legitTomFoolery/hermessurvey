import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gsecsurvey/models/question.dart';
import 'package:gsecsurvey/models/survey_response.dart';
import 'package:gsecsurvey/screens/admin/widgets/expandable_response_card.dart';
import 'package:gsecsurvey/services/firestore_service.dart';
import 'package:gsecsurvey/services/response_admin_service.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as ExcelLib;
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';

class ResponseManagementScreen extends StatefulWidget {
  const ResponseManagementScreen({Key? key}) : super(key: key);

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
      // Date filter
      if (_startDate != null || _endDate != null) {
        try {
          final responseDate = DateFormat('MM/dd/yyyy').parse(response.date);
          if (_startDate != null && responseDate.isBefore(_startDate!)) {
            return false;
          }
          if (_endDate != null && responseDate.isAfter(_endDate!)) {
            return false;
          }
        } catch (e) {
          // If date parsing fails, exclude this response from date filtering
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
      final excel = ExcelLib.Excel.createExcel();
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
            ExcelLib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = headers[i];
        cell.cellStyle = ExcelLib.CellStyle(bold: true);
      }

      // Add data rows
      for (int rowIndex = 0; rowIndex < _filteredResponses.length; rowIndex++) {
        final response = _filteredResponses[rowIndex];
        final dataRow = rowIndex + 1;

        // Basic response info
        sheet
            .cell(ExcelLib.CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: dataRow))
            .value = response.id;
        sheet
            .cell(ExcelLib.CellIndex.indexByColumnRow(
                columnIndex: 1, rowIndex: dataRow))
            .value = response.formattedDateTime;
        sheet
            .cell(ExcelLib.CellIndex.indexByColumnRow(
                columnIndex: 2, rowIndex: dataRow))
            .value = response.date;
        sheet
            .cell(ExcelLib.CellIndex.indexByColumnRow(
                columnIndex: 3, rowIndex: dataRow))
            .value = response.rotation;
        sheet
            .cell(ExcelLib.CellIndex.indexByColumnRow(
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
                .cell(ExcelLib.CellIndex.indexByColumnRow(
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _responses.isEmpty
                ? _buildEmptyState()
                : _buildResponsesList(),
      ),
      floatingActionButton: _responses.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showExportModal,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.save_alt, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No survey responses found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Survey responses will appear here once users submit surveys',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
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
          child: ListView.builder(
            itemCount: _filteredResponses.length,
            itemBuilder: (context, index) {
              final response = _filteredResponses[index];
              return ExpandableResponseCard(
                response: response,
                questions: _questions,
                onUpdate: _loadData,
                isExpanded: _expandedResponseId == response.id,
                onExpanded: () => _onResponseExpanded(response.id),
                onCollapsed: _onResponseCollapsed,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
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
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      if (_activeFilterCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_filteredResponses.length}/${_responses.length} responses',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_activeFilterCount > 0)
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear All'),
                    ),
                  Icon(
                    _isFilterExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
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
    final hasDateFilter = _startDate != null && _endDate != null;
    return ActionChip(
      avatar: Icon(
        Icons.date_range,
        size: 18,
        color: hasDateFilter ? Colors.white : Colors.grey[600],
      ),
      label: Text(
        hasDateFilter
            ? '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}'
            : 'Date Range',
        style: TextStyle(
          color: hasDateFilter ? Colors.white : Colors.grey[700],
          fontSize: 12,
        ),
      ),
      backgroundColor:
          hasDateFilter ? Theme.of(context).primaryColor : Colors.grey[200],
      onPressed: _selectDateRange,
    );
  }

  Widget _buildRotationDropdown() {
    final rotations = _rotationAttendingMap.keys.toList();

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _selectedRotation != null
            ? Theme.of(context).primaryColor
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRotation,
          hint: Text(
            'Rotation',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
          style: TextStyle(
            color: _selectedRotation != null ? Colors.white : Colors.grey[700],
            fontSize: 12,
          ),
          dropdownColor: Colors.white,
          icon: Icon(
            Icons.arrow_drop_down,
            color: _selectedRotation != null ? Colors.white : Colors.grey[600],
            size: 18,
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child:
                  Text('All Rotations', style: TextStyle(color: Colors.black)),
            ),
            ...rotations.map((rotation) => DropdownMenuItem<String>(
                  value: rotation,
                  child: Text(rotation,
                      style: const TextStyle(color: Colors.black)),
                )),
          ],
          onChanged: _onRotationChanged,
        ),
      ),
    );
  }

  Widget _buildAttendingDropdown() {
    final attendingOptions = _rotationAttendingMap[_selectedRotation!] ?? [];

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _selectedAttending != null
            ? Theme.of(context).primaryColor
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAttending,
          hint: Text(
            'Attending',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
          style: TextStyle(
            color: _selectedAttending != null ? Colors.white : Colors.grey[700],
            fontSize: 12,
          ),
          dropdownColor: Colors.white,
          icon: Icon(
            Icons.arrow_drop_down,
            color: _selectedAttending != null ? Colors.white : Colors.grey[600],
            size: 18,
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child:
                  Text('All Attending', style: TextStyle(color: Colors.black)),
            ),
            ...attendingOptions.map((attending) => DropdownMenuItem<String>(
                  value: attending,
                  child: Text(attending,
                      style: const TextStyle(color: Colors.black)),
                )),
          ],
          onChanged: _onAttendingChanged,
        ),
      ),
    );
  }
}
