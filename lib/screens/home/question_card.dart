import 'package:flutter/material.dart';
import 'package:gsecsurvey/models/question.dart';
import 'package:gsecsurvey/services/response_provider.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

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

    return Card(
      color: theme.colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Text(
              widget.question.name,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            Consumer<ResponseProvider>(
              builder: (context, responseProvider, child) {
                return _buildResponseWidget(responseProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseWidget(ResponseProvider responseProvider) {
    final theme = AdaptiveTheme.of(context).theme;
    switch (widget.question.type) {
      case 'radio':
      case 'yesNo':
        return _buildRadioButtons();
      case 'dropdown':
        return _buildDropdown(widget.question.options);
      case 'rotation':
        return _buildDropdown(
            widget.question.rotationDetails?.keys.toList() ?? [],
            isRotation: true);
      case 'attending':
        return responseProvider.attendings.isNotEmpty
            ? _buildDropdown(responseProvider.attendings, isAttending: true)
            : Text(
                'Please select a rotation first.',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.shadow,
                ),
              );
      case 'date':
        return _buildDatePicker();
      default:
        return _buildTextField();
    }
  }

  Widget _buildRadioButtons() {
    final theme = AdaptiveTheme.of(context).theme;
    return Column(
      children: widget.question.options.map((option) {
        return RadioListTile<String>(
          title: Text(
            option,
            style: theme.textTheme.displayLarge?.copyWith(
              color: theme.colorScheme.shadow,
            ),
          ),
          value: option,
          groupValue: _selectedOption,
          activeColor: theme.colorScheme.primary,
          onChanged: (value) {
            setState(() {
              _selectedOption = value;
              widget.onResponse(widget.question.id, value!);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTextField() {
    final theme = AdaptiveTheme.of(context).theme;

    return Padding(
      padding:
          const EdgeInsets.only(top: 8.0), // Adds padding above the TextField
      child: TextField(
        controller: _textController,
        cursorColor:
            theme.colorScheme.primary, // Sets the cursor color to primary color
        decoration: InputDecoration(
          labelText: 'Your Answer',
          labelStyle:
              TextStyle(color: theme.colorScheme.shadow), // Custom label color
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme
                  .colorScheme.surface, // Custom border color when not focused
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  theme.colorScheme.primary, // Custom border color when focused
            ),
          ),
          border: const OutlineInputBorder(), // Default border style
        ),
        style: TextStyle(color: theme.colorScheme.shadow), // Custom text color
        onChanged: (value) {
          widget.onResponse(widget.question.id, value);
        },
      ),
    );
  }

  Widget _buildDropdown(List<String> options,
      {bool isRotation = false, bool isAttending = false}) {
    final theme = AdaptiveTheme.of(context).theme;

    // Sort the options list alphabetically
    List<String> sortedOptions = List.from(options)..sort();

    if (isAttending && !sortedOptions.contains(_selectedOption)) {
      _selectedOption = null;
    }

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: theme.colorScheme.surface, // Dropdown background color
        primaryColor:
            theme.colorScheme.primary, // Item text color when selected
        textTheme: theme.textTheme,
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSecondary, // Dropdown arrow icon color
        ),
      ),
      child: DropdownButton<String>(
        value: _selectedOption,
        hint: Text(
          'Select Option',
          style: TextStyle(color: theme.colorScheme.shadow), // Hint text color
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedOption = newValue;
            widget.onResponse(widget.question.id, newValue!);
            if (isRotation) {
              context.read<ResponseProvider>().clearResponse('attending');
              context.read<ResponseProvider>().updateAttendings(
                  widget.question.rotationDetails?[newValue] ?? []);
            }
          });
        },
        items: sortedOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: theme.colorScheme.shadow),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePicker() {
    final theme = AdaptiveTheme.of(context).theme;
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme:
                        AdaptiveTheme.of(context).theme.colorScheme.copyWith(
                              primary: theme.colorScheme.primary,
                              shadow: theme.colorScheme
                                  .shadow, // Customize this to change the text color
                              surface: theme.colorScheme.secondary,
                              onSurface: theme.colorScheme.shadow,
                            ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                _selectedOption = "${pickedDate.toLocal()}"
                    .split(' ')[0]; // Format date as YYYY-MM-DD
                widget.onResponse(widget.question.id, _selectedOption!);
              });
            }
          },
          child: Text(
            _selectedOption == null ? 'Select Date' : _selectedOption!,
            style: theme.textTheme.displayLarge?.copyWith(
              color: theme.colorScheme.shadow,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
