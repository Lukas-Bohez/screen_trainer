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
  final TextEditingController _nameController = TextEditingController(text: 'Main profile');
  bool _isChild = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    final controller = context.read<ScreenTrainerController>();
    final profile = controller.settingsRepository.createProfileTemplate(
      name: _nameController.text.trim().isEmpty ? 'Main profile' : _nameController.text.trim(),
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
                  Text(Strings.onboardingIntro),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: Strings.profileNameLabel,
                      hintText: Strings.profileNameHint,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isChild,
                    onChanged: (value) => setState(() => _isChild = value),
                    title: Text(_isChild ? Strings.childProfileLabel : Strings.adultProfileLabel),
                    subtitle: Text(_isChild ? Strings.childProfileSubtitle : Strings.adultSkipPath),
                  ),
                  FilledButton(
                    onPressed: _createProfile,
                    child: const Text(Strings.createProfile),
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