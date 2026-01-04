import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:garage/core/core.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:garage/router/app_router.dart';
import 'bloc/premium_bloc.dart';
import 'bloc/premium_event.dart';
import 'bloc/premium_state.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PremiumBloc(subscriptionRepository: getIt.repo.subscription),
      child: const PremiumView(),
    );
  }
}

class PremiumView extends StatelessWidget {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PremiumBloc, PremiumState>(
      listenWhen: (previous, current) =>
          previous.status == PremiumStatus.purchasing &&
          current.status == PremiumStatus.success,
      listener: (context, state) {
        if (state.status == PremiumStatus.success && state.isPro) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.darkSurface,
              title: Text(
                'premium.successTitle'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
              content: Text(
                'premium.successDesc'.tr(),
                style: const TextStyle(color: AppTheme.systemGray),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'premium.successButton'.tr(),
                    style: const TextStyle(color: AppTheme.accentColor),
                  ),
                ),
              ],
            ),
          );
        } else if (state.status == PremiumStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'premium.failureMessage'.tr(),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.dashboardBg,
        body: Stack(
          children: [
            // Background Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.darkSurface,
                      const Color(0xFF1A1A1A),
                      AppTheme.dashboardBg,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            CustomScrollView(
              slivers: [
                const _PremiumAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PremiumHeader(),
                        const SizedBox(height: 32),
                        const _FeatureList(),
                        const SizedBox(height: 40),
                        const _OfferingsSection(),
                        const SizedBox(height: 24),
                        const _RestoreButton(),
                        const SizedBox(height: 24),
                        const _LegalLinks(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Loading Overlay
            BlocBuilder<PremiumBloc, PremiumState>(
              builder: (context, state) {
                if (state.status == PremiumStatus.purchasing) {
                  return Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.dashboardAccentRed,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumAppBar extends StatelessWidget {
  const _PremiumAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      pinned: true,
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.dashboardAccentRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.dashboardAccentRed.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text(
                    'GARAGE PRO',
                    style: TextStyle(
                      color: AppTheme.dashboardAccentRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                if (state.isPro) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.verified,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'premium.proMemberStatus'.tr(),
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'premium.unlockAllFeatures'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'premium.upgradeProDesc'.tr(),
              style: const TextStyle(color: AppTheme.systemGray, fontSize: 16),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.block,
        'title': 'premium.features.noAds'.tr(),
        'desc': 'premium.features.noAdsDesc'.tr(),
      },
      {
        'icon': Icons.cloud_done,
        'title': 'premium.features.cloudSync'.tr(),
        'desc': 'premium.features.cloudSyncDesc'.tr(),
      },
      {
        'icon': Icons.insights,
        'title': 'premium.features.stats'.tr(),
        'desc': 'premium.features.statsDesc'.tr(),
      },
      {
        'icon': Icons.support_agent,
        'title': 'premium.features.support'.tr(),
        'desc': 'premium.features.supportDesc'.tr(),
      },
    ];

    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      f['icon'] as IconData,
                      color: AppTheme.accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          f['desc'] as String,
                          style: const TextStyle(
                            color: AppTheme.systemGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _OfferingsSection extends StatelessWidget {
  const _OfferingsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        if (state.status == PremiumStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isPro) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentColor, width: 1),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.accentColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'premium.thanksSupport'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'premium.allAccess'.tr(),
                  style: const TextStyle(
                    color: AppTheme.systemGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (state.offerings.isEmpty) {
          return Center(
            child: Text(
              'premium.noOfferings'.tr(),
              style: const TextStyle(color: AppTheme.systemGray),
            ),
          );
        }

        final currentOffering = state.offerings.first;
        final packages = currentOffering.availablePackages;

        return Column(
          children: packages.map((p) => _PackageCard(package: p)).toList(),
        );
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Package package;
  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final isYearly = package.packageType == PackageType.annual;

    return GestureDetector(
      onTap: () => context.read<PremiumBloc>().add(PurchasePackage(package)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isYearly
              ? AppTheme.dashboardAccentRed.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isYearly
                ? AppTheme.dashboardAccentRed
                : AppTheme.whiteTransparent15,
            width: isYearly ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getPackageTitle(package),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isYearly) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.dashboardAccentRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'premium.bestChoice'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPackageDescription(package),
                    style: const TextStyle(
                      color: AppTheme.systemGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              package.storeProduct.priceString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPackageTitle(Package p) {
    switch (p.packageType) {
      case PackageType.monthly:
        return 'premium.monthlyPlan'.tr();
      case PackageType.annual:
        return 'premium.annualPlan'.tr();
      default:
        return p.storeProduct.title;
    }
  }

  String _getPackageDescription(Package p) {
    switch (p.packageType) {
      case PackageType.monthly:
        return 'premium.monthlyDesc'.tr();
      case PackageType.annual:
        return 'premium.annualDesc'.tr();
      default:
        return '';
    }
  }
}

class _RestoreButton extends StatelessWidget {
  const _RestoreButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.read<PremiumBloc>().add(RestorePurchases()),
        child: Text(
          'premium.restorePurchases'.tr(),
          style: TextStyle(
            color: AppTheme.systemGray,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _linkButton(
          context,
          'settings.termsOfService'.tr(),
          AppPath.termsOfService,
        ),
        const Text(' | ', style: TextStyle(color: AppTheme.systemGray)),
        _linkButton(
          context,
          'settings.privacyPolicy'.tr(),
          AppPath.privacyPolicy,
        ),
      ],
    );
  }

  Widget _linkButton(BuildContext context, String text, AppPath path) {
    return TextButton(
      onPressed: () => context.goPath(path),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.systemGray,
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
