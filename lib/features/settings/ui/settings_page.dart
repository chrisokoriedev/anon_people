import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/providers.dart';
import '../data/settings_repository.dart';
import '../../auth/data/auth_repository.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  bool _muteNotifications = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final biometricEnabled = await settingsRepo.getBiometricEnabled();
    final notificationsEnabled = await settingsRepo.getNotificationsEnabled();
    final muteNotifications = await settingsRepo.getMuteNotifications();
    
    setState(() {
      _biometricEnabled = biometricEnabled;
      _notificationsEnabled = notificationsEnabled;
      _muteNotifications = muteNotifications;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(authStateChangesProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileSection(user),
                const SizedBox(height: 24),
                _buildAppearanceSection(themeMode),
                const SizedBox(height: 24),
                _buildSecuritySection(),
                const SizedBox(height: 24),
                _buildNotificationSection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
                const SizedBox(height: 24),
                _buildSignOutSection(),
              ],
            ),
    );
  }

  Widget _buildProfileSection(User? user) {
    return _SettingsSection(
      title: 'Profile',
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? Text(user?.displayName?.substring(0, 1).toUpperCase() ?? 'A')
                : null,
          ),
          title: Text(user?.displayName ?? 'Anonymous User'),
          subtitle: Text(user?.email ?? 'No email'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to edit profile page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit profile coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(ThemeMode themeMode) {
    return _SettingsSection(
      title: 'Appearance',
      children: [
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Theme'),
          subtitle: Text(_getThemeModeText(themeMode)),
          trailing: DropdownButton<ThemeMode>(
            value: themeMode,
            items: ThemeMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(_getThemeModeText(mode)),
              );
            }).toList(),
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(mode);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _SettingsSection(
      title: 'Security',
      children: [
        FutureBuilder<bool>(
          future: ref.read(settingsRepositoryProvider).isBiometricAvailable(),
          builder: (context, snapshot) {
            final isAvailable = snapshot.data ?? false;
            return SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric Authentication'),
              subtitle: Text(isAvailable ? 'Use fingerprint or face ID' : 'Not available on this device'),
              value: _biometricEnabled && isAvailable,
              onChanged: isAvailable ? (value) async {
                if (value) {
                  final authenticated = await ref.read(settingsRepositoryProvider).authenticateWithBiometrics();
                  if (authenticated) {
                    await ref.read(settingsRepositoryProvider).setBiometricEnabled(true);
                    setState(() => _biometricEnabled = true);
                  }
                } else {
                  await ref.read(settingsRepositoryProvider).setBiometricEnabled(false);
                  setState(() => _biometricEnabled = false);
                }
              } : null,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Change Password'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Implement password change
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password change coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _SettingsSection(
      title: 'Notifications',
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive push notifications'),
          value: _notificationsEnabled,
          onChanged: (value) async {
            await ref.read(settingsRepositoryProvider).setNotificationsEnabled(value);
            setState(() => _notificationsEnabled = value);
          },
        ),
        if (_notificationsEnabled)
          SwitchListTile(
            secondary: const Icon(Icons.volume_off),
            title: const Text('Mute Notifications'),
            subtitle: const Text('Silence all notifications'),
            value: _muteNotifications,
            onChanged: (value) async {
              await ref.read(settingsRepositoryProvider).setMuteNotifications(value);
              setState(() => _muteNotifications = value);
            },
          ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _SettingsSection(
      title: 'About',
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to privacy policy
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Privacy policy coming soon')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to terms of service
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Terms of service coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSignOutSection() {
    return _SettingsSection(
      title: 'Account',
      children: [
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );
            
            if (confirmed == true) {
              await ref.read(authRepositoryProvider).signOut();
            }
          },
        ),
      ],
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}
