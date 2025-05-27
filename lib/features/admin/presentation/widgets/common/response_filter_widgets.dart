import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:intl/intl.dart';

/// Compact date picker widget for filters - smaller version of home page DatePickerWidget
class CompactDatePickerWidget extends StatelessWidget {
  final String? selectedDate;
  final ValueChanged<String> onDateSelected;
  final String hint;

  const CompactDatePickerWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.hint = 'Select Date',
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;
    final dateFormat = DateFormat('yyyy-MM-dd');
    final displayFormat = DateFormat('MM/dd/yy');

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selectedDate != null
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          FocusScope.of(context).unfocus();
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate != null
                ? DateTime.tryParse(selectedDate!) ?? DateTime.now()
                : DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: theme.colorScheme.primary,
                    shadow: theme.colorScheme.shadow,
                    surface: theme.colorScheme.secondary,
                    onSurface: theme.colorScheme.shadow,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            final formattedDate = dateFormat.format(pickedDate);
            onDateSelected(formattedDate);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 16,
              color: selectedDate != null
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.shadow,
            ),
            const SizedBox(width: 6),
            Text(
              selectedDate != null
                  ? displayFormat.format(DateTime.parse(selectedDate!))
                  : hint,
              style: TextStyle(
                color: selectedDate != null
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.shadow,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact dropdown widget for filters - smaller version of home page DropdownWidget
class CompactDropdownWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onChanged;
  final String hint;
  final bool showAllOption;

  const CompactDropdownWidget({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    required this.hint,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selectedOption != null
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: theme.colorScheme.surface,
          primaryColor: theme.colorScheme.primary,
          textTheme: theme.textTheme,
          iconTheme: IconThemeData(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedOption,
            hint: Text(
              hint,
              style: TextStyle(
                color: theme.colorScheme.shadow,
                fontSize: 12,
              ),
            ),
            style: TextStyle(
              color: selectedOption != null
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.shadow,
              fontSize: 12,
            ),
            dropdownColor: theme.colorScheme.secondary,
            icon: Icon(
              Icons.arrow_drop_down,
              color: selectedOption != null
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.shadow,
              size: 18,
            ),
            items: [
              if (showAllOption)
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'All ${hint}s',
                    style: TextStyle(
                      color: theme.colorScheme.onSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ..._buildDropdownItems(options, theme),
            ],
            onChanged: (String? newValue) {
              FocusScope.of(context).unfocus();
              onChanged(newValue);
            },
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      List<String> options, ThemeData theme) {
    List<String> sortedOptions = List.from(options)..sort();
    return sortedOptions.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.onSecondary,
            fontSize: 12,
          ),
        ),
      );
    }).toList();
  }
}

/// Date range picker widget for filters
class CompactDateRangeWidget extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPressed;

  const CompactDateRangeWidget({
    super.key,
    this.startDate,
    this.endDate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;
    final hasDateFilter = startDate != null && endDate != null;
    final displayFormat = DateFormat('MM/dd');

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: hasDateFilter
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 16,
              color: hasDateFilter
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.shadow,
            ),
            const SizedBox(width: 6),
            Text(
              hasDateFilter
                  ? '${displayFormat.format(startDate!)} - ${displayFormat.format(endDate!)}'
                  : 'Date Range',
              style: TextStyle(
                color: hasDateFilter
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.shadow,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
