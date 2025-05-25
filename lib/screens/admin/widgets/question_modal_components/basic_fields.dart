import 'package:flutter/material.dart';

class BasicFields extends StatelessWidget {
  final TextEditingController orderController;
  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController typeController;
  final Function(String?) onTypeChanged;

  const BasicFields({
    Key? key,
    required this.orderController,
    required this.idController,
    required this.nameController,
    required this.typeController,
    required this.onTypeChanged,
  }) : super(key: key);

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
        TextFormField(
          controller: idController,
          decoration: const InputDecoration(
            labelText: 'ID',
            hintText: 'Unique identifier',
          ),
        ),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Question Text',
            hintText: 'Enter the question text',
          ),
        ),
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
