import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../../user_profile/providers/user_profile_provider.dart';
import '../../user_profile/screens/user_profile_screen.dart';
import '../../user_profile/screens/profile_summary_screen.dart';
import '../../usage_data/providers/usage_data_provider.dart';
import '../../usage_data/screens/usage_data_entry_screen.dart';
import '../../usage_data/screens/usage_history_screen.dart';
import '../../usage_data/models/usage_data_model.dart';
import '../../onboarding/screens/onboarding_screen.dart';

/// Home Screen - Main Dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final profileProvider = context.read<UserProfileProvider>();
    await profileProvider.initialize();
    
    if (profileProvider.hasProfile) {
      final usageProvider = context.read<UsageDataProvider>();
      await usageProvider.initialize(profileProvider.currentProfile!.id);
    }
    
    setState(() => _isInitialized = true);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.backgroundGradient,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryBlue),
                SizedBox(height: 24),
                Text(
                  'Loading...',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, _) {
        if (!profileProvider.hasProfile) {
          return _buildOnboardingScreen();
        }
        return _buildDashboard();
      },
    );
  }

  Widget _buildOnboardingScreen() {
    return const OnboardingScreen();
  }

  Widget _buildDashboard() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: AppColors.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDashboardHeader(),
                    _buildTotalEmissionCard(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildCategoryBreakdown(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDashboardHeader() {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.currentProfile;
        final greeting = _getGreeting();
        
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.name ?? 'User',
                      style: AppTextStyles.heading2,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToProfile(),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.buttonShadow,
                  ),
                  child: Center(
                    child: Text(
                      profile?.name.isNotEmpty == true
                          ? profile!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildTotalEmissionCard() {
    return Consumer<UsageDataProvider>(
      builder: (context, provider, _) {
        final todayEmission = provider.getTodayTotalEmission();
        final weekEmission = provider.getWeekTotalEmission();
        final totalEmission = provider.totalCO2Emission;

        return GradientCard(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Total Carbon Footprint',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalEmission.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'kg CO₂',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStat(
                      'Today',
                      '${todayEmission.toStringAsFixed(1)} kg',
                      Icons.today_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniStat(
                      'This Week',
                      '${weekEmission.toStringAsFixed(1)} kg',
                      Icons.date_range_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Log Activity',
                  'Record usage',
                  Icons.add_circle_outline_rounded,
                  AppColors.primaryBlue,
                  () => _navigateToAddEntry(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'View History',
                  'Past entries',
                  Icons.history_rounded,
                  AppColors.travelColor,
                  () => _navigateToHistory(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Consumer<UsageDataProvider>(
      builder: (context, provider, _) {
        final emissions = provider.emissionsByCategory;
        
        if (emissions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emissions by Category',
                style: AppTextStyles.heading4,
              ),
              const SizedBox(height: 16),
              ...UsageCategory.values.where((c) => emissions.containsKey(c)).map((category) {
                final emission = emissions[category] ?? 0;
                final total = emissions.values.fold<double>(0, (a, b) => a + b);
                final percentage = total > 0 ? (emission / total * 100) : 0.0;
                
                return _buildCategoryRow(category, emission, percentage);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryRow(UsageCategory category, double emission, double percentage) {
    final color = _getCategoryColor(category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                category.icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.displayName,
                      style: AppTextStyles.labelLarge,
                    ),
                    Text(
                      '${emission.toStringAsFixed(1)} kg',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<UsageDataProvider>(
      builder: (context, provider, _) {
        final recentEntries = provider.entries.take(3).toList();
        
        if (recentEntries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GlassCard(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 48,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No activities logged yet',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your daily activities',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: AppTextStyles.heading4,
                  ),
                  TextButton(
                    onPressed: () => _navigateToHistory(),
                    child: Text(
                      'View All',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...recentEntries.map((entry) => _buildRecentEntryCard(entry)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentEntryCard(UsageDataEntry entry) {
    final color = _getCategoryColor(entry.category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                entry.category.icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.type.displayName,
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.value.toStringAsFixed(1)} ${entry.unit}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.co2Emission.toStringAsFixed(2)} kg',
                style: AppTextStyles.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'CO₂',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.buttonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToAddEntry(),
          borderRadius: BorderRadius.circular(30),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Log Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Color _getCategoryColor(UsageCategory category) {
    switch (category) {
      case UsageCategory.electricity:
        return AppColors.electricityColor;
      case UsageCategory.fuel:
        return AppColors.fuelColor;
      case UsageCategory.travel:
        return AppColors.travelColor;
      case UsageCategory.appliance:
        return AppColors.applianceColor;
      case UsageCategory.waste:
        return AppColors.wasteColor;
    }
  }

  Future<void> _refreshData() async {
    final profileProvider = context.read<UserProfileProvider>();
    if (profileProvider.hasProfile) {
      final usageProvider = context.read<UsageDataProvider>();
      await usageProvider.refresh(profileProvider.currentProfile!.id);
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSummaryScreen(),
      ),
    );
  }

  void _navigateToAddEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UsageDataEntryScreen(),
      ),
    );
    
    if (result == true) {
      _refreshData();
    }
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UsageHistoryScreen(),
      ),
    );
  }
}
