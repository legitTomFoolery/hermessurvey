import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerService {
  static Future<DateTimeRange?> showCustomDateRangePicker({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  }) async {
    return await showDialog<DateTimeRange?>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _DateRangePickerDialog(
          initialStartDate: initialStartDate,
          initialEndDate: initialEndDate,
        );
      },
    );
  }
}

class _DateRangePickerDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const _DateRangePickerDialog({
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<_DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Date Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Start Date
          ListTile(
            title: const Text('Start Date'),
            subtitle: Text(_startDate != null
                ? DateFormat('MM/dd/yyyy').format(_startDate!)
                : 'Select start date'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectStartDate,
          ),
          // End Date
          ListTile(
            title: const Text('End Date'),
            subtitle: Text(_endDate != null
                ? DateFormat('MM/dd/yyyy').format(_endDate!)
                : 'Select end date'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectEndDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_startDate != null && _endDate != null) {
              Navigator.of(context).pop(DateTimeRange(
                start: _startDate!,
                end: _endDate!,
              ));
            } else {
              // Show error if both dates aren't selected
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select both start and end dates'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
