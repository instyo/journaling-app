import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journaling/features/user/cubit/user_cubit.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _descriptionController = TextEditingController();

    // Populate controllers if user data is already loaded
    final userState = context.read<UserCubit>().state;
    if (userState is UserProfileLoaded) {
      _nameController.text = userState.user.name;
      _usernameController.text = userState.user.username ?? '';
      _descriptionController.text = userState.user.description ?? '';
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<UserCubit>().updateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          } else if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
            // Update local controllers if new data comes from successful update
            _nameController.text = state.user.name;
            _usernameController.text = state.user.username ?? '';
            _descriptionController.text = state.user.description ?? '';
          } else if (state is UserProfileLoaded) {
            // Update controllers if data is loaded, especially useful if screen
            // was opened before data was fully loaded
            _nameController.text = state.user.name;
            _usernameController.text = state.user.username ?? '';
            _descriptionController.text = state.user.description ?? '';
          }
        },
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      hintText: 'Optional',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'About Me',
                      border: OutlineInputBorder(),
                      hintText: 'Tell us about yourself...',
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Extension to capitalize first letter of a string (from journal_write_screen.dart)
extension StringCasingExtension on String {
  String capitalize() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
