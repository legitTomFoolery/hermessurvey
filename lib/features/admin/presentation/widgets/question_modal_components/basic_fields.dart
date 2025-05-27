import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return Column(
      children: [
        TextFormField(
          controller: orderController,
          decoration: const InputDecoration(
            labelText: 'Order (number)',
            hintText: 'e.g., 1, 2, 3',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppConstants.defaultSpacing),
        TextFormField(
          controller: idController,
          decoration: const InputDecoration(
            labelText: 'ID',
            hintText: 'Only letters and hyphens allowed',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\-]')),
          ],
        ),
        const SizedBox(height: AppConstants.defaultSpacing),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Question Text',
            hintText: 'Enter the question text',
          ),
        ),
        const SizedBox(height: AppConstants.defaultSpacing),
        DropdownButtonFormField<String>(
          value: typeController.text.isEmpty ? null : typeController.text,
          decoration: const InputDecoration(
            labelText: 'Question Type',
          ),
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
