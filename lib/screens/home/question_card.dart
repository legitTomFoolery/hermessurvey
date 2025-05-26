import 'package:flutter/material.dart';
import 'package:gsecsurvey/models/question.dart';
import 'package:gsecsurvey/services/response_provider.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:intl/intl.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(String, String) onResponse;
  final String? initialResponse;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onResponse,
    this.initialResponse,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? _selectedOption;
  final TextEditingController _textController = TextEditingController();
  final _dateFormat = DateFormat('yyyy-MM-dd');

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

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;
    final responseProvider = Provider.of<ResponseProvider>(context);

    return GestureDetector(
      onTap: () {
        // Unfocus any active text fields when tapping on this question
        FocusScope.of(context).unfocus();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Center(
                child: Text(
                  widget.question.name,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.onSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              _buildResponseWidget(responseProvider, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponseWidget(
      ResponseProvider responseProvider, ThemeData theme) {
    switch (widget.question.type) {
      case 'radio':
      case 'yesNo':
        return _buildRadioButtons(theme);
      case 'dropdown':
        return _buildDropdown(widget.question.options, theme);
      case 'rotation':
        return _buildDropdown(
          widget.question.rotationDetails?.keys.toList() ?? [],
          theme,
          isRotation: true,
        );
      case 'attending':
        return responseProvider.attendings.isNotEmpty
            ? _buildDropdown(responseProvider.attendings, theme,
                isAttending: true)
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
        return _buildDatePicker(theme);
      default:
        return _buildTextField(theme);
    }
  }

  Widget _buildRadioButtons(ThemeData theme) {
    return Column(
      children: widget.question.options.map((option) {
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
            groupValue: _selectedOption,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              if (value != null) {
                // Unfocus any active text fields when selecting a radio option
                FocusScope.of(context).unfocus();
                setState(() {
                  _selectedOption = value;
                  widget.onResponse(widget.question.id, value);
                });
              }
            },
            dense: true,
            visualDensity: const VisualDensity(vertical: -4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: TextField(
        controller: _textController,
        cursorColor: theme.colorScheme.primary,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: theme.colorScheme.shadow,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: 'Your Answer',
          alignLabelWithHint: true,
          labelStyle: TextStyle(color: theme.colorScheme.shadow),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.colorScheme.surface,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: (value) {
          widget.onResponse(widget.question.id, value);
        },
      ),
    );
  }

  Widget _buildDropdown(List<String> options, ThemeData theme,
      {bool isRotation = false, bool isAttending = false}) {
    if (isAttending && !options.contains(_selectedOption)) {
      _selectedOption = null;
    }

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
          value: _selectedOption,
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
              // Unfocus any active text fields when selecting a dropdown option
              FocusScope.of(context).unfocus();
              setState(() {
                _selectedOption = newValue;
                widget.onResponse(widget.question.id, newValue);
                if (isRotation) {
                  final provider = context.read<ResponseProvider>();
                  provider.clearResponse('attending');
                  provider.updateAttendings(
                      widget.question.rotationDetails?[newValue] ?? []);
                }
              });
            }
          },
          items: _buildDropdownItems(options, theme),
        ),
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: () async {
          // Unfocus any active text fields when opening date picker
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
            final formattedDate = _dateFormat.format(pickedDate);
            setState(() {
              _selectedOption = formattedDate;
              widget.onResponse(widget.question.id, formattedDate);
            });
          }
        },
        child: Text(
          _selectedOption ?? 'Select Date',
          style: theme.textTheme.displayLarge?.copyWith(
            color: theme.colorScheme.shadow,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
