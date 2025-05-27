import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:intl/intl.dart';

import 'package:gsecsurvey/features/home/data/models/question_model.dart';
import 'package:gsecsurvey/shared/data/services/response_provider.dart';
import 'package:gsecsurvey/shared/utils/typedefs.dart';

/// Widget responsible for rendering different types of question responses
class QuestionResponseWidget extends StatefulWidget {
  final Question question;
  final QuestionResponseCallback onResponse;
  final String? initialResponse;

  const QuestionResponseWidget({
    super.key,
    required this.question,
    required this.onResponse,
    this.initialResponse,
  });

  @override
  State<QuestionResponseWidget> createState() => _QuestionResponseWidgetState();
}

class _QuestionResponseWidgetState extends State<QuestionResponseWidget> {
  String? _selectedOption;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialResponse;
    if (widget.question.type == 'text' && widget.initialResponse != null) {
      _textController.text = widget.initialResponse!;
    }
    if (widget.question.type == 'rotation' && widget.initialResponse != null) {
      context.read<ResponseProvider>().updateAttendings(
          widget.question.rotationDetails?[widget.initialResponse!] ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;
    final responseProvider = Provider.of<ResponseProvider>(context);

    switch (widget.question.type) {
      case 'radio':
      case 'yesNo':
        return RadioButtonsWidget(
          options: widget.question.options,
          selectedOption: _selectedOption,
          onChanged: _handleOptionChanged,
        );
      case 'dropdown':
        return DropdownWidget(
          options: widget.question.options,
          selectedOption: _selectedOption,
          onChanged: _handleOptionChanged,
        );
      case 'rotation':
        return DropdownWidget(
          options: widget.question.rotationDetails?.keys.toList() ?? [],
          selectedOption: _selectedOption,
          onChanged: (value) => _handleRotationChanged(value, responseProvider),
          isRotation: true,
        );
      case 'attending':
        return responseProvider.attendings.isNotEmpty
            ? DropdownWidget(
                options: responseProvider.attendings,
                selectedOption: _selectedOption,
                onChanged: _handleOptionChanged,
                isAttending: true,
              )
            : Center(
                child: Text(
                  'Please select a rotation first.',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.shadow,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
      case 'date':
        return DatePickerWidget(
          selectedDate: _selectedOption,
          onDateSelected: _handleOptionChanged,
        );
      default:
        return TextFieldWidget(
          controller: _textController,
          onChanged: (value) => widget.onResponse(widget.question.id, value),
        );
    }
  }

  void _handleOptionChanged(String value) {
    setState(() {
      _selectedOption = value;
      widget.onResponse(widget.question.id, value);
    });
  }

  void _handleRotationChanged(String value, ResponseProvider provider) {
    setState(() {
      _selectedOption = value;
      widget.onResponse(widget.question.id, value);
      provider.clearResponse('attending');
      provider.updateAttendings(widget.question.rotationDetails?[value] ?? []);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

/// Widget for radio button options
class RadioButtonsWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onChanged;

  const RadioButtonsWidget({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Column(
      children: options.map((option) {
        return Theme(
          data: Theme.of(context).copyWith(
            listTileTheme: const ListTileThemeData(
              horizontalTitleGap: 8,
            ),
          ),
          child: RadioListTile<String>(
            title: Text(
              option,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.shadow,
                fontSize: 16,
              ),
            ),
            value: option,
            groupValue: selectedOption,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              if (value != null) {
                FocusScope.of(context).unfocus();
                onChanged(value);
              }
            },
            dense: true,
            visualDensity: const VisualDensity(vertical: -4),
          ),
        );
      }).toList(),
    );
  }
}

/// Widget for dropdown options
class DropdownWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onChanged;
  final bool isRotation;
  final bool isAttending;

  const DropdownWidget({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    this.isRotation = false,
    this.isAttending = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    // Reset selected option if it's not in the current options (for attending)
    final currentSelectedOption =
        isAttending && !options.contains(selectedOption)
            ? null
            : selectedOption;

    return Center(
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: theme.colorScheme.surface,
          primaryColor: theme.colorScheme.primary,
          textTheme: theme.textTheme,
          iconTheme: IconThemeData(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        child: DropdownButton<String>(
          value: currentSelectedOption,
          hint: Text(
            'Select Option',
            style: TextStyle(
              color: theme.colorScheme.shadow,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              FocusScope.of(context).unfocus();
              onChanged(newValue);
            }
          },
          items: _buildDropdownItems(options, theme),
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
            color: theme.colorScheme.shadow,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }).toList();
  }
}

/// Widget for text input
class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: TextField(
        controller: controller,
        cursorColor: theme.colorScheme.primary,
        style: TextStyle(
          color: theme.colorScheme.onSecondary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: 'Your Answer',
          labelStyle: TextStyle(color: theme.colorScheme.shadow),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          fillColor: theme.colorScheme.secondary,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

/// Widget for date picker
class DatePickerWidget extends StatelessWidget {
  final String? selectedDate;
  final ValueChanged<String> onDateSelected;

  const DatePickerWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Center(
      child: TextButton(
        onPressed: () async {
          FocusScope.of(context).unfocus();
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
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
        child: Text(
          selectedDate ?? 'Select Date',
          style: theme.textTheme.displayLarge?.copyWith(
            color: theme.colorScheme.shadow,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
