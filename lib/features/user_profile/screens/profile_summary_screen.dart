import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../models/user_profile_model.dart';
import '../providers/user_profile_provider.dart';
import 'user_profile_screen.dart';

/// Profile Summary Screen - View and Edit Profile
class ProfileSummaryScreen extends StatelessWidget {
  const ProfileSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<UserProfileProvider>(
            builder: (context, provider, _) {
              final profile = provider.currentProfile;
              
              if (profile == null) {
                return const EmptyState(
                  icon: Icons.person_off_rounded,
                  title: 'No Profile Found',
                  message: 'Create a profile to get started',
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context, profile),
                    const SizedBox(height: 24),
                    _buildProfileCard(profile),
                    const SizedBox(height: 24),
                    _buildEmissionFactorsCard(profile),
                    const SizedBox(height: 24),
                    _buildActionsCard(context, provider),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.softShadow,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'My Profile',
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 32),
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppShadows.buttonShadow,
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 4),
          Text(
            '${profile.city}, ${Region.fromCode(profile.region).name}',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Details',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: '${profile.age} years',
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.location_city_rounded,
            label: 'City',
            value: profile.city,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.public_rounded,
            label: 'Region',
            value: Region.fromCode(profile.region).name,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.directions_run_rounded,
            label: 'Lifestyle',
            value: profile.lifestyleType.displayName,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Member Since',
            value: _formatDate(profile.createdAt),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
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

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.divider,
      height: 1,
    );
  }

  Widget _buildEmissionFactorsCard(UserProfile profile) {
    final region = Region.fromCode(profile.region);
    
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Emission Factors',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildEmissionFactorRow(
            label: 'Electricity Factor',
            value: '${region.electricityFactor} kg CO₂/kWh',
            description: 'Based on ${region.name} grid',
          ),
          const SizedBox(height: 16),
          _buildEmissionFactorRow(
            label: 'Lifestyle Multiplier',
            value: '${profile.baselineEmissionFactor}x',
            description: profile.lifestyleType.description,
          ),
        ],
      ),
    );
  }

  Widget _buildEmissionFactorRow({
    required String label,
    required String value,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, UserProfileProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SecondaryButton(
            text: 'Edit Profile',
            icon: Icons.edit_rounded,
            onPressed: () => _navigateToEdit(context),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showDeleteConfirmation(context, provider),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.error, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Delete Profile',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserProfileScreen(isEditing: true),
      ),
    );
    // Profile will refresh automatically via provider
  }

  void _showDeleteConfirmation(BuildContext context, UserProfileProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Profile?'),
          ],
        ),
        content: const Text(
          'This will permanently delete your profile and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteProfile();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
