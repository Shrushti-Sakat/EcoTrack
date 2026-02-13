import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../user_profile/screens/user_profile_screen.dart';

/// Onboarding Screen with illustrations and Get Started button
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Track Your\nCarbon Footprint',
      subtitle: 'Monitor your daily activities and understand your environmental impact with precision',
      illustration: OnboardingIllustration.earth,
      colors: [AppColors.primaryBlue, AppColors.primaryBlueLight],
    ),
    OnboardingData(
      title: 'Log Activities\nWith Ease',
      subtitle: 'Record electricity, travel, fuel consumption, and more in just a few taps',
      illustration: OnboardingIllustration.activities,
      colors: [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
    ),
    OnboardingData(
      title: 'Get Personalized\nInsights',
      subtitle: 'Receive region-specific calculations and discover ways to reduce your footprint',
      illustration: OnboardingIllustration.insights,
      colors: [const Color(0xFF7B1FA2), const Color(0xFFBA68C8)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _navigateToCreateProfile();
    }
  }

  void _navigateToCreateProfile() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const UserProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _navigateToCreateProfile,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              // Bottom Section
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    final isFirstPage = data.illustration == OnboardingIllustration.earth;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // App Name on first page
          if (isFirstPage) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    ).createShader(bounds),
                    child: const Text(
                      'EcoTrack1',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Carbon Companion',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Illustration
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: _buildIllustration(data),
          ),
          const Spacer(flex: 1),
          // Text Content
          Text(
            data.title,
            style: AppTextStyles.heading1.copyWith(
              fontSize: 32,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            data.subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildIllustration(OnboardingData data) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            data.colors[1].withValues(alpha: 0.2),
            data.colors[0].withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative circles
          ...List.generate(3, (index) {
            return Positioned(
              child: Container(
                width: 200 + (index * 40),
                height: 200 + (index * 40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: data.colors[0].withValues(alpha: 0.1 - (index * 0.03)),
                    width: 1.5,
                  ),
                ),
              ),
            );
          }),
          // Main illustration container
          _buildMainIllustration(data),
        ],
      ),
    );
  }

  Widget _buildMainIllustration(OnboardingData data) {
    switch (data.illustration) {
      case OnboardingIllustration.earth:
        return _buildEarthIllustration(data.colors);
      case OnboardingIllustration.activities:
        return _buildActivitiesIllustration(data.colors);
      case OnboardingIllustration.insights:
        return _buildInsightsIllustration(data.colors);
    }
  }

  Widget _buildEarthIllustration(List<Color> colors) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Earth globe
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Land masses simulation
              Positioned(
                top: 25,
                left: 30,
                child: Container(
                  width: 50,
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 25,
                child: Container(
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              // Shine effect
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Orbiting leaf icon
        Positioned(
          top: 10,
          right: 50,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Icon(
              Icons.eco_rounded,
              color: colors[0],
              size: 24,
            ),
          ),
        ),
        // CO2 badge
        Positioned(
          bottom: 20,
          left: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_outlined, color: colors[0], size: 16),
                const SizedBox(width: 4),
                Text(
                  'CO₂',
                  style: TextStyle(
                    color: colors[0],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesIllustration(List<Color> colors) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Central device/phone
        Container(
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.add_chart_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: colors[0].withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors[0].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        // Floating activity icons
        Positioned(
          top: 20,
          left: 30,
          child: _buildFloatingIcon(Icons.bolt_rounded, colors, 0),
        ),
        Positioned(
          top: 40,
          right: 25,
          child: _buildFloatingIcon(Icons.directions_car_rounded, colors, 1),
        ),
        Positioned(
          bottom: 30,
          left: 25,
          child: _buildFloatingIcon(Icons.local_gas_station_rounded, colors, 2),
        ),
        Positioned(
          bottom: 50,
          right: 35,
          child: _buildFloatingIcon(Icons.delete_outline_rounded, colors, 3),
        ),
      ],
    );
  }

  Widget _buildFloatingIcon(IconData icon, List<Color> colors, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 150)),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: colors[0],
          size: 22,
        ),
      ),
    );
  }

  Widget _buildInsightsIllustration(List<Color> colors) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Chart container
        Container(
          width: 160,
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar(0.6, colors[1]),
              _buildChartBar(0.9, colors[0]),
              _buildChartBar(0.4, colors[1]),
              _buildChartBar(0.75, colors[0]),
            ],
          ),
        ),
        // Trend arrow
        Positioned(
          top: 10,
          right: 40,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.4),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.trending_down_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        // Lightbulb - tips
        Positioned(
          bottom: 10,
          left: 35,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: colors[0],
              size: 22,
            ),
          ),
        ),
        // Percentage badge
        Positioned(
          top: 30,
          left: 30,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Text(
              '-15%',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartBar(double height, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: height),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Container(
          width: 24,
          height: 70 * value,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              final isActive = index == _currentPage;
              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: isActive ? 32 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: isActive ? AppGradients.primaryGradient : null,
                    color: isActive ? null : AppColors.inputBorder,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          // Get Started button
          Row(
            children: [
              // Back arrow (only show after first page)
              AnimatedOpacity(
                opacity: _currentPage > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      : null,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.inputBorder,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              if (_currentPage > 0) const SizedBox(width: 16),
              // Main action button
              Expanded(
                child: GestureDetector(
                  onTap: _goToNextPage,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Data classes
enum OnboardingIllustration { earth, activities, insights }

class OnboardingData {
  final String title;
  final String subtitle;
  final OnboardingIllustration illustration;
  final List<Color> colors;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.colors,
  });
}
