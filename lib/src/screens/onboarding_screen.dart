import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/screen_trainer_controller.dart';
import '../utils/strings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Configurator');
  bool _isChild = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    final controller = context.read<ScreenTrainerController>();
    final profile = controller.settingsRepository.createProfileTemplate(
      name: _nameController.text.trim().isEmpty ? 'Configurator' : _nameController.text.trim(),
      isChild: _isChild,
    );
    await controller.addProfile(profile);
    await controller.setActiveProfile(profile.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(Strings.onboardingTitle, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  const Text('Create the first profile, then use the curtain and challenge screens to test the loop end to end.'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Profile name'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isChild,
                    onChanged: (value) => setState(() => _isChild = value),
                    title: const Text('Child profile'),
                    subtitle: const Text('Use this when the profile is managed by a configurator.'),
                  ),
                  FilledButton(
                    onPressed: _createProfile,
                    child: const Text('Create profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}