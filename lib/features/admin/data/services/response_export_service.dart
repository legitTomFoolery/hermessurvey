import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/features/home/data/models/survey_response_model.dart';

class ResponseExportService {
  static Future<void> exportToExcel({
    required BuildContext context,
    required List<SurveyResponse> responses,
    required List<Question> questions,
  }) async {
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
      for (final question in questions) {
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
      for (int rowIndex = 0; rowIndex < responses.length; rowIndex++) {
        final response = responses[rowIndex];
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
        for (final question in questions) {
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

        await _saveFile(context, bytes, fileName);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting to Excel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> _saveFile(
      BuildContext context, List<int> bytes, String fileName) async {
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
          if (context.mounted) {
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

        if (context.mounted) {
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

  static void showExportModal({
    required BuildContext context,
    required int responseCount,
    required VoidCallback onExport,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Survey Responses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export $responseCount filtered responses to Excel?'),
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
              onExport();
            },
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }
}
