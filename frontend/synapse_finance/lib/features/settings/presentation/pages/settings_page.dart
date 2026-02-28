import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _biometricsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;
    final user = context.select(
      (AuthCubit c) => c.state.status == AuthStatus.authenticated ? c.state.user : null,
    );

    final bg = isDark ? const Color(0xFF0A1A0A) : const Color(0xFFF0F4F0);
    final rowBg = isDark ? const Color(0xFF122112) : const Color(0xFFFFFFFF);
    final onSurface = isDark ? Colors.white : const Color(0xFF0D1B0D);
    final onSurfaceSecondary = isDark ? const Color(0xFF8B9E8B) : const Color(0xFF4A5C4A);
    final divider = isDark ? const Color(0xFF243624) : const Color(0xFFD8E8D8);
    final sectionLabel = isDark ? const Color(0xFF6B7E6B) : const Color(0xFF6B7C6B);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: bg,
              automaticallyImplyLeading: false,
              title: Text(
                'Settings',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),

            // ── Profile header ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildProfile(user, isDark, onSurface, onSurfaceSecondary),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── ACCOUNT & PROFILE ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionGroup(
                label: 'ACCOUNT & PROFILE',
                labelColor: sectionLabel,
                rowBg: rowBg,
                divider: divider,
                onSurface: onSurface,
                onSurfaceSecondary: onSurfaceSecondary,
                rows: [
                  _SettingsRow(
                    iconBg: const Color(0xFF1E6FDB),
                    icon: Icons.person_outline_rounded,
                    label: 'Personal Information',
                  ),
                  _SettingsRow(
                    iconBg: const Color(0xFF7C3AED),
                    icon: Icons.credit_card_rounded,
                    label: 'Subscription Plan',
                    trailing: 'AI Premium',
                  ),
                  _SettingsRow(
                    iconBg: const Color(0xFF059669),
                    icon: Icons.layers_rounded,
                    label: 'Data Export & Backup',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── SECURITY ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionGroup(
                label: 'SECURITY',
                labelColor: sectionLabel,
                rowBg: rowBg,
                divider: divider,
                onSurface: onSurface,
                onSurfaceSecondary: onSurfaceSecondary,
                rows: [
                  _SettingsRow(
                    iconBg: const Color(0xFF374151),
                    icon: Icons.face_retouching_natural_rounded,
                    label: 'FaceID / Biometrics',
                    customTrailing: Switch(
                      value: _biometricsEnabled,
                      onChanged: (v) => setState(() => _biometricsEnabled = v),
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF3B82F6),
                    ),
                  ),
                  _SettingsRow(
                    iconBg: const Color(0xFFD97706),
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Passcode',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── NOTIFICATIONS ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionGroup(
                label: 'NOTIFICATIONS',
                labelColor: sectionLabel,
                rowBg: rowBg,
                divider: divider,
                onSurface: onSurface,
                onSurfaceSecondary: onSurfaceSecondary,
                rows: [
                  _SettingsRow(
                    iconBg: const Color(0xFFDC2626),
                    icon: Icons.notifications_outlined,
                    label: 'Push Notifications',
                  ),
                  _SettingsRow(
                    iconBg: const Color(0xFFD97706),
                    icon: Icons.email_outlined,
                    label: 'Email Reports',
                    trailing: 'Weekly',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── APP EXPERIENCE ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionGroup(
                label: 'APP EXPERIENCE',
                labelColor: sectionLabel,
                rowBg: rowBg,
                divider: divider,
                onSurface: onSurface,
                onSurfaceSecondary: onSurfaceSecondary,
                rows: [
                  _SettingsRow(
                    iconBg: const Color(0xFF2563EB),
                    icon: Icons.dark_mode_outlined,
                    label: 'Appearance',
                    trailing: isDark ? 'Dark' : 'Light',
                    onTap: () => _showAppearancePicker(context, themeMode),
                  ),
                  _SettingsRow(
                    iconBg: const Color(0xFF7C3AED),
                    icon: Icons.attach_money_rounded,
                    label: 'Currency',
                    trailing: 'USD (\$)',
                  ),
                  _SettingsRow(
                    iconBg: const Color(0xFF1E6FDB),
                    icon: Icons.tune_rounded,
                    label: 'AI Chat Personalization',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Log Out button ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _LogoutButton(rowBg: rowBg, divider: divider),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Footer ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildFooter(onSurfaceSecondary),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(
    User? user,
    bool isDark,
    Color onSurface,
    Color onSurfaceSecondary,
  ) {
    final name = user?.fullName ?? 'Guest';
    final email = user?.email ?? '';
    final initials = _initials(name);

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: const Color(0xFF4ADE80).withValues(alpha: 0.15),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4ADE80),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              color: onSurfaceSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 14,
                  color: Color(0xFF3B82F6),
                ),
                const SizedBox(width: 6),
                const Text(
                  'AI Premium Member',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(Color secondaryColor) {
    return Column(
      children: [
        Text(
          'Synapse Finance v1.0.0 (Build 1)',
          style: TextStyle(
            color: secondaryColor.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: const Color(0xFF3B82F6),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Privacy Policy'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '•',
                style: TextStyle(
                  color: secondaryColor.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: const Color(0xFF3B82F6),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Terms of Service'),
            ),
          ],
        ),
      ],
    );
  }

  void _showAppearancePicker(BuildContext context, ThemeMode current) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF122112) : const Color(0xFFFFFFFF);
    final onSurface = isDark ? Colors.white : const Color(0xFF0D1B0D);
    final secondary = isDark ? const Color(0xFF8B9E8B) : const Color(0xFF4A5C4A);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: context.read<ThemeCubit>(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Appearance',
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _AppearanceOption(
                  label: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  selected: current == ThemeMode.dark,
                  onTap: () {
                    sheetContext.read<ThemeCubit>().setTheme(ThemeMode.dark);
                    Navigator.of(sheetContext).pop();
                  },
                  onSurface: onSurface,
                  secondary: secondary,
                ),
                const SizedBox(height: 12),
                _AppearanceOption(
                  label: 'Light',
                  icon: Icons.light_mode_rounded,
                  selected: current == ThemeMode.light,
                  onTap: () {
                    sheetContext.read<ThemeCubit>().setTheme(ThemeMode.light);
                    Navigator.of(sheetContext).pop();
                  },
                  onSurface: onSurface,
                  secondary: secondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ─── Section group ──────────────────────────────────────────────────────────

class _SectionGroup extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color rowBg;
  final Color divider;
  final Color onSurface;
  final Color onSurfaceSecondary;
  final List<_SettingsRow> rows;

  const _SectionGroup({
    required this.label,
    required this.labelColor,
    required this.rowBg,
    required this.divider,
    required this.onSurface,
    required this.onSurfaceSecondary,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: rowBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: rows.map((row) {
                final isLast = rows.last == row;
                return _SettingsRowTile(
                  row: row,
                  showDivider: !isLast,
                  divider: divider,
                  onSurface: onSurface,
                  onSurfaceSecondary: onSurfaceSecondary,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings row model ──────────────────────────────────────────────────────

class _SettingsRow {
  final Color iconBg;
  final IconData icon;
  final String label;
  final String? trailing;
  final Widget? customTrailing;
  final VoidCallback? onTap;
  final bool isLast;

  const _SettingsRow({
    required this.iconBg,
    required this.icon,
    required this.label,
    this.trailing,
    this.customTrailing,
    this.onTap,
    this.isLast = false,
  });
}

// ─── Settings row tile ───────────────────────────────────────────────────────

class _SettingsRowTile extends StatelessWidget {
  final _SettingsRow row;
  final bool showDivider;
  final Color divider;
  final Color onSurface;
  final Color onSurfaceSecondary;

  const _SettingsRowTile({
    required this.row,
    required this.showDivider,
    required this.divider,
    required this.onSurface,
    required this.onSurfaceSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: row.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: row.iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(row.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    row.label,
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (row.customTrailing != null)
                  row.customTrailing!
                else ...[
                  if (row.trailing != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        row.trailing!,
                        style: TextStyle(
                          color: onSurfaceSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: onSurfaceSecondary,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 0.5,
              indent: 64,
              color: divider,
            ),
        ],
      ),
    );
  }
}

// ─── Log out button ──────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final Color rowBg;
  final Color divider;

  const _LogoutButton({required this.rowBg, required this.divider});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: rowBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.read<AuthCubit>().logout(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.logout_rounded,
                color: Color(0xFFF85149),
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFFF85149),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Appearance option ───────────────────────────────────────────────────────

class _AppearanceOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color onSurface;
  final Color secondary;

  const _AppearanceOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.onSurface,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF4ADE80)
                : secondary.withValues(alpha: 0.3),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF4ADE80) : secondary, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 20),
          ],
        ),
      ),
    );
  }
}
