import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:intl/intl.dart';

class ResponseFilterSection extends StatelessWidget {
  final int filteredCount;
  final int totalCount;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onClearFilters;
  final int activeFilterCount;
  final Widget child;

  const ResponseFilterSection({
    super.key,
    required this.filteredCount,
    required this.totalCount,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onClearFilters,
    required this.activeFilterCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: onToggleExpanded,
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
                      if (activeFilterCount > 0)
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
                    '$filteredCount/$totalCount responses',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (activeFilterCount > 0)
                    TextButton(
                      onPressed: onClearFilters,
                      child: Text(
                        'Clear Filters',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.shadow,
                  ),
                ],
              ),
            ),
          ),

          // Expandable filter controls
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }
}

class DateRangeChip extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPressed;

  const DateRangeChip({
    super.key,
    this.startDate,
    this.endDate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;
    final hasDateFilter = startDate != null && endDate != null;

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
            ? '${DateFormat('MM/dd').format(startDate!)} - ${DateFormat('MM/dd').format(endDate!)}'
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
      onPressed: onPressed,
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool showAllOption;

  const FilterDropdown({
    super.key,
    this.value,
    required this.hint,
    required this.options,
    required this.onChanged,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: value != null
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: theme.colorScheme.shadow,
              fontSize: 12,
            ),
          ),
          style: TextStyle(
            color: value != null
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.shadow,
            fontSize: 12,
          ),
          dropdownColor: theme.colorScheme.secondary,
          icon: Icon(
            Icons.arrow_drop_down,
            color: value != null
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
                  style: TextStyle(color: theme.colorScheme.onSecondary),
                ),
              ),
            ...options.map((option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(color: theme.colorScheme.onSecondary),
                  ),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
