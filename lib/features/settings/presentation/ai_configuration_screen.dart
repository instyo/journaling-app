import 'package:flutter/material.dart';

class AIConfigurationScreen extends StatefulWidget {
  const AIConfigurationScreen({super.key});

  @override
  State<AIConfigurationScreen> createState() => _AIConfigurationScreenState();
}

class _AIConfigurationScreenState extends State<AIConfigurationScreen> {
  final TextEditingController apiUrlController = TextEditingController();
  final TextEditingController apiTokenController = TextEditingController();
  final TextEditingController modelController = TextEditingController();

  @override
  void dispose() {
    apiUrlController.dispose();
    apiTokenController.dispose();
    modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configure AI Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: apiUrlController,
            decoration: InputDecoration(labelText: 'API URL'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the API URL';
              }
              return null;
            },
          ),
          TextFormField(
            controller: apiTokenController,
            decoration: InputDecoration(labelText: 'API Token'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the API Token';
              }
              return null;
            },
          ),
          TextFormField(
            controller: modelController,
            decoration: InputDecoration(labelText: 'Model'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the Model';
              }
              return null;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (apiUrlController.text.isNotEmpty &&
                apiTokenController.text.isNotEmpty &&
                modelController.text.isNotEmpty) {
              Navigator.of(context).pop((
                apiUrlController.text,
                apiTokenController.text,
                modelController.text,
              ));
            } else {
              // Optionally show a message to the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill in all fields')),
              );
            }
          },
          child: Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
