import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile userProfile;

  const ProfileHeader({
    super.key,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              userProfile.displayName.isNotEmpty
                  ? userProfile.displayName[0].toUpperCase()
                  : '?',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userProfile.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            userProfile.email,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
