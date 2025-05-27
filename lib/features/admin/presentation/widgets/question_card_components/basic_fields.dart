import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'package:gsecsurvey/app/config/app_constants.dart';

class BasicFields extends StatelessWidget {
  final TextEditingController orderController;
  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController typeController;
  final Function(String?) onTypeChanged;

  const BasicFields({
    super.key,
    required this.orderController,
    required this.idController,
    required this.nameController,
    required this.typeController,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context).theme;

    return Column(
      children: [
        TextFormField(
          controller: orderController,
          decoration: InputDecoration(
            labelText: 'Order (number)',
            hintText: 'e.g., 1, 2, 3',
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            fillColor: theme.colorScheme.secondary,
            filled: true,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppConstants.defaultSpacing + 8),
        TextFormField(
          controller: idController,
          decoration: InputDecoration(
            labelText: 'ID',
            hintText: 'Only letters and hyphens allowed',
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            fillColor: theme.colorScheme.secondary,
            filled: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\-]')),
          ],
        ),
        const SizedBox(height: AppConstants.defaultSpacing + 8),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Question Text',
            hintText: 'Enter the question text',
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            fillColor: theme.colorScheme.secondary,
            filled: true,
          ),
        ),
        const SizedBox(height: AppConstants.defaultSpacing + 8),
        DropdownButtonFormField<String>(
          value: typeController.text.isEmpty ? null : typeController.text,
          decoration: InputDecoration(
            labelText: 'Question Type',
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            fillColor: theme.colorScheme.secondary,
            filled: true,
          ),
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'text', child: Text('Text Input')),
            DropdownMenuItem(
                value: 'radio', child: Text('Multiple Choice (Radio)')),
            DropdownMenuItem(value: 'yesNo', child: Text('Yes/No')),
            DropdownMenuItem(value: 'dropdown', child: Text('Dropdown')),
            DropdownMenuItem(value: 'date', child: Text('Date Picker')),
            DropdownMenuItem(value: 'rotation', child: Text('Rotation')),
            DropdownMenuItem(value: 'attending', child: Text('Attending')),
          ],
          onChanged: onTypeChanged,
        ),
      ],
    );
  }
}
