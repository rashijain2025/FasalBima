import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';

// NEW: Localization imports
import '../../localization/app_localizations.dart';
import '../../localization/locale_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('profile_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => localeProvider.toggleLocale(),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;

          if (user == null) {
            return Center(
              child: Text(loc.t('profile_user_not_found')),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(context, loc, user),
                const SizedBox(height: 16),
                _buildQuickActionsRow(context, loc),
                const SizedBox(height: 16),
                _buildProfileInfo(context, loc, user),
                const SizedBox(height: 16),
                _buildSettingsSection(context, loc),
                const SizedBox(height: 24),
                _buildLogoutButton(context, loc),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- HEADER: FARMER CARD STYLE ----------------

  Widget _buildProfileHeader(
      BuildContext context, AppLocalizations loc, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: user.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.profileImageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person,
                            size: 40, color: Colors.white);
                      },
                    ),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),
          // Name + farmer badge + simple text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Simple greeting type line, easy to read
                  loc.t('profile_greeting_simple'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.agriculture,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '👨‍🌾 ${loc.t('profile_farmer_badge')}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        user.phone,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- QUICK ACTIONS (BIG BUTTONS) ----------------

  Widget _buildQuickActionsRow(BuildContext context, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('profile_quick_actions'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                icon: Icons.edit,
                title: loc.t('profile_quick_edit'),
                subtitle: loc.t('profile_quick_edit_sub'),
                color: AppColors.primary.withOpacity(0.1),
                iconColor: AppColors.primary,
                onTap: () {
                  // abhi ke liye simple snackbar (edit profile TODO)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.t('profile_quick_edit_sub')),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                icon: Icons.help_outline,
                title: loc.t('profile_quick_help'),
                subtitle: loc.t('profile_quick_help_sub'),
                color: AppColors.secondary.withOpacity(0.12),
                iconColor: AppColors.secondary,
                onTap: () {
                  _showHelpBottomSheet(context, loc);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: iconColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- PROFILE INFO CARD ----------------

  Widget _buildProfileInfo(
      BuildContext context, AppLocalizations loc, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('profile_info_title'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.person,
            label: loc.t('profile_name'),
            value: user.name,
          ),
          _buildInfoRow(
            icon: Icons.email,
            label: loc.t('profile_email'),
            value: user.email,
          ),
          _buildInfoRow(
            icon: Icons.phone,
            label: loc.t('profile_phone'),
            value: user.phone,
          ),
          _buildInfoRow(
            icon: Icons.location_on,
            label: loc.t('profile_address'),
            value: user.address,
          ),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: loc.t('profile_member_since'),
            value: _formatDate(user.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SETTINGS SECTION ----------------

  Widget _buildSettingsSection(BuildContext context, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.t('profile_settings'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 24),
          _buildSettingsItem(
            context: context,
            icon: Icons.help,
            title: loc.t('profile_help'),
            subtitle: loc.t('profile_help_sub'),
            onTap: () => _showHelpBottomSheet(context, loc),
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.info,
            title: loc.t('profile_about'),
            subtitle: loc.t('profile_about_sub'),
            onTap: () => _showAboutDialog(context, loc),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // ---------------- LOGOUT BUTTON ----------------

  Widget _buildLogoutButton(BuildContext context, AppLocalizations loc) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, loc),
        icon: const Icon(Icons.logout),
        label: Text(loc.t('logout')),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ---------------- HELP & ABOUT & LOGOUT DIALOGS ----------------

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _showAboutDialog(BuildContext context, AppLocalizations loc) {
    showAboutDialog(
      context: context,
      applicationName: loc.t('app_title'),
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.agriculture, color: Colors.white, size: 30),
      ),
      children: [
        Text(loc.t('profile_about_desc')),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(loc.t('logout')),
        content: Text(loc.t('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.t('logout')),
          ),
        ],
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.support_agent,
                        color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.t('profile_help'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                loc.t('profile_help_sub'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // future: yahan se call / whatsapp / help nav kar sakte ho
                  },
                  icon: const Icon(Icons.call),
                  label: Text(loc.t('profile_quick_help')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
