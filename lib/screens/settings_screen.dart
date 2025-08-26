// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _saboteurEnabled = false;
  bool _diceRollEnabled = false;
  String _selectedLanguage = 'English'; // Default language

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final fb = context.read<FirebaseService>();
    final settings = await fb.fetchRoomCreationSettings();
    setState(() {
      _saboteurEnabled = settings['saboteurEnabled'] ?? false;
      _diceRollEnabled = settings['diceRollEnabled'] ?? false;
      // If you implement language persistence, load it here
    });
  }

  Future<void> _saveSettings() async {
    final fb = context.read<FirebaseService>();
    await fb.saveRoomCreationSettings(_saboteurEnabled, _diceRollEnabled);
    // If you implement language persistence, save it here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Saboteur Feature Switch
            ListTile(
              title: const Text('Enable Saboteur Mode'),
              trailing: Switch(
                value: _saboteurEnabled,
                onChanged: (value) {
                  setState(() {
                    _saboteurEnabled = value;
                  });
                  _saveSettings(); // Save settings immediately on change
                },
              ),
            ),
            const Divider(),

            // Dice Roll Feature Switch
            ListTile(
              title: const Text('Enable Dice Roll Feature'),
              trailing: Switch(
                value: _diceRollEnabled,
                onChanged: (value) {
                  setState(() {
                    _diceRollEnabled = value;
                  });
                  _saveSettings(); // Save settings immediately on change
                },
              ),
            ),
            const Divider(),

            // Language Selector
            ListTile(
              title: const Text('Language'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLanguage = newValue;
                    });
                    // _saveSettings(); // Language preference would be saved here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Language set to $_selectedLanguage (Note: Full localization not implemented)')),
                    );
                  }
                },
                items: <String>['English', 'العربية'] // English and Arabic options
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            const Divider(),

            // Future settings can be added here
          ],
        ),
      ),
    );
  }
}
