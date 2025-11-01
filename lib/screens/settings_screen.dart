
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  int _notificationTimingDays = 0; // Default to 'on the day'
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0); // Default to 9:00 AM

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _notificationTimingDays = prefs.getInt('notificationTimingDays') ?? 0;
      final hour = prefs.getInt('notificationTimeHour') ?? 9;
      final minute = prefs.getInt('notificationTimeMinute') ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _updateNotificationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
    });

    if (!value) {
      await _notificationService.cancelAllNotifications();
    } else {
      // TODO: Re-schedule all notifications based on current settings
    }
  }

  Future<void> _updateNotificationTiming(int? days) async {
    if (days == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationTimingDays', days);
    setState(() {
      _notificationTimingDays = days;
    });
    // TODO: Re-schedule all notifications
  }

  Future<void> _selectNotificationTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked != null && picked != _notificationTime) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notificationTimeHour', picked.hour);
      await prefs.setInt('notificationTimeMinute', picked.minute);
      setState(() {
        _notificationTime = picked;
      });
      // TODO: Re-schedule all notifications
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timingOptions = {
      0: l10n.onTheDay,
      1: "1 ${l10n.daysBefore}",
      3: "3 ${l10n.daysBefore}",
      7: "7 ${l10n.daysBefore}",
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(l10n.notificationSettings, context),
          SwitchListTile(
            title: Text(l10n.notificationsOnOff),
            value: _notificationsEnabled,
            onChanged: _updateNotificationEnabled,
          ),
          ListTile(
            title: Text(l10n.notificationTiming),
            trailing: DropdownButton<int>(
              value: _notificationTimingDays,
              items: timingOptions.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: _updateNotificationTiming,
            ),
            enabled: _notificationsEnabled,
          ),
          ListTile(
            title: Text(l10n.notificationTime),
            trailing: Text(_notificationTime.format(context)),
            onTap: () => _selectNotificationTime(context),
            enabled: _notificationsEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
