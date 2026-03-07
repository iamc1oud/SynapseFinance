import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

const _avatarBaseUrl = 'https://cdn.jsdelivr.net/gh/alohe/avatars/png';

const _avatarOptions = [
  '$_avatarBaseUrl/vibrent_1.png',
  '$_avatarBaseUrl/vibrent_2.png',
  '$_avatarBaseUrl/vibrent_3.png',
  '$_avatarBaseUrl/vibrent_4.png',
  '$_avatarBaseUrl/vibrent_5.png',
  '$_avatarBaseUrl/vibrent_6.png',
  '$_avatarBaseUrl/vibrent_7.png',
  '$_avatarBaseUrl/vibrent_8.png',
  '$_avatarBaseUrl/vibrent_9.png',
  '$_avatarBaseUrl/vibrent_10.png',
  '$_avatarBaseUrl/vibrent_11.png',
  '$_avatarBaseUrl/vibrent_12.png',
  '$_avatarBaseUrl/vibrent_13.png',
  '$_avatarBaseUrl/vibrent_14.png',
  '$_avatarBaseUrl/vibrent_15.png',
  '$_avatarBaseUrl/vibrent_16.png',
  '$_avatarBaseUrl/vibrent_17.png',
  '$_avatarBaseUrl/vibrent_18.png',
  '$_avatarBaseUrl/vibrent_19.png',
  '$_avatarBaseUrl/vibrent_20.png',
  '$_avatarBaseUrl/vibrent_21.png',
  '$_avatarBaseUrl/vibrent_22.png',
  '$_avatarBaseUrl/vibrent_23.png',
  '$_avatarBaseUrl/vibrent_24.png',
  '$_avatarBaseUrl/vibrent_25.png',
  '$_avatarBaseUrl/vibrent_26.png',
  '$_avatarBaseUrl/vibrent_27.png',
  '$_avatarBaseUrl/memo_1.png',
  '$_avatarBaseUrl/memo_2.png',
  '$_avatarBaseUrl/memo_3.png',
  '$_avatarBaseUrl/memo_4.png',
  '$_avatarBaseUrl/memo_5.png',
  '$_avatarBaseUrl/memo_6.png',
  '$_avatarBaseUrl/memo_7.png',
  '$_avatarBaseUrl/memo_8.png',
  '$_avatarBaseUrl/memo_9.png',
  '$_avatarBaseUrl/memo_10.png',
  '$_avatarBaseUrl/bluey_1.png',
  '$_avatarBaseUrl/bluey_2.png',
  '$_avatarBaseUrl/bluey_3.png',
  '$_avatarBaseUrl/bluey_4.png',
  '$_avatarBaseUrl/bluey_5.png',
  '$_avatarBaseUrl/bluey_6.png',
  '$_avatarBaseUrl/bluey_7.png',
  '$_avatarBaseUrl/bluey_8.png',
  '$_avatarBaseUrl/bluey_9.png',
  '$_avatarBaseUrl/bluey_10.png',
];

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
  String? _selectedAvatarUrl;
  bool _saving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _selectedAvatarUrl = user?.avatarUrl;

    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    _checkChanges();
  }

  void _checkChanges() {
    final user = context.read<AuthCubit>().state.user;
    final changed = _firstNameController.text != (user?.firstName ?? '') ||
        _lastNameController.text != (user?.lastName ?? '') ||
        _selectedAvatarUrl != (user?.avatarUrl ?? '');
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final error = await context.read<AuthCubit>().updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          avatarUrl: _selectedAvatarUrl ?? '',
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

  void _showAvatarPicker(AppColorScheme c) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.textHint.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Choose Avatar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: c.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedAvatarUrl != null &&
                      _selectedAvatarUrl!.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedAvatarUrl = '';
                          _checkChanges();
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Remove',
                        style: TextStyle(color: c.error, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: _avatarOptions.length,
                itemBuilder: (context, index) {
                  final url = _avatarOptions[index];
                  final isSelected = _selectedAvatarUrl == url;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarUrl = url;
                        _checkChanges();
                      });
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: c.primary, width: 3)
                            : null,
                      ),
                      child: CircleAvatar(
                        backgroundColor: c.surfaceLight,
                        backgroundImage: NetworkImage(url),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
                      GestureDetector(
                        onTap: () => _showAvatarPicker(c),
                        child: Stack(
                          children: [
                            _buildAvatar(c, user?.email ?? ''),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: c.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: c.background,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 14,
                                  color: c.background,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildAvatar(AppColorScheme c, String email) {
    if (_selectedAvatarUrl != null && _selectedAvatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 44,
        backgroundColor: c.surfaceLight,
        backgroundImage: NetworkImage(_selectedAvatarUrl!),
      );
    }
    return CircleAvatar(
      radius: 44,
      backgroundColor: c.primary.withAlpha(40),
      child: Text(
        _initials(
          _firstNameController.text,
          _lastNameController.text,
          email,
        ),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: c.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    AppColorScheme c, {
    TextEditingController? controller,
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
