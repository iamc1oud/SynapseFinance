import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  bool _saving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');

    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final user = context.read<AuthCubit>().state.user;
    final changed =
        _firstNameController.text != (user?.firstName ?? '') ||
        _lastNameController.text != (user?.lastName ?? '');
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final error = await context.read<AuthCubit>().updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    final c = context.appColors;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: c.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _hasChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated!'),
          backgroundColor: c.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Personal Information',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _hasChanges && !_saving ? _save : null,
            child: _saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.primary,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: _hasChanges ? c.primary : c.textHint,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar preview
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: c.primary.withAlpha(40),
                        child: Text(
                          _initials(
                            _firstNameController.text,
                            _lastNameController.text,
                            user?.email ?? '',
                          ),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: c.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(color: c.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // First Name
                _FieldLabel('First Name', c),
                const SizedBox(height: 8),
                _buildTextField(
                  c,
                  controller: _firstNameController,
                  hintText: 'Enter your first name',
                ),
                const SizedBox(height: 24),

                // Last Name
                _FieldLabel('Last Name', c),
                const SizedBox(height: 8),
                _buildTextField(
                  c,
                  controller: _lastNameController,
                  hintText: 'Enter your last name',
                ),
                const SizedBox(height: 24),

                // Email (read-only)
                _FieldLabel('Email', c),
                const SizedBox(height: 8),
                _buildTextField(
                  c,
                  initialValue: user?.email ?? '',
                  controller: _emailController,
                  hintText: '',
                  readOnly: true,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    AppColorScheme c, {
    TextEditingController? controller,
    String? initialValue,
    required String hintText,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(
        color: readOnly ? c.textSecondary : c.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: c.textHint),
        filled: true,
        fillColor: readOnly ? c.surfaceLight : c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.borderFocused, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  String _initials(String firstName, String lastName, String email) {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isNotEmpty && l.isNotEmpty) {
      return '${f[0]}${l[0]}'.toUpperCase();
    }
    if (f.isNotEmpty) return f[0].toUpperCase();
    if (l.isNotEmpty) return l[0].toUpperCase();
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final AppColorScheme c;

  const _FieldLabel(this.text, this.c);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: c.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
