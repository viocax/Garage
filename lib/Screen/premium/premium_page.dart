import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/di/service_locator.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
    return Scaffold(
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
                  const Text(
                    '您已是 PRO 成員',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '解鎖所有進階功能',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '升級 Pro 成員，享受無限同步與數據追蹤。',
              style: TextStyle(color: AppTheme.systemGray, fontSize: 16),
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
      {'icon': Icons.block, 'title': '無廣告體驗', 'desc': '移除所有插頁式與橫幅廣告。'},
      {'icon': Icons.cloud_done, 'title': '雲端自動同步', 'desc': '讓您的數據在多台設備間無縫切換。'},
      {'icon': Icons.insights, 'title': '進階統計數據', 'desc': '包含油耗趨勢與年度花費對比。'},
      {
        'icon': Icons.support_agent,
        'title': '優先客服支援',
        'desc': '我們的新功能將優先提供給 Pro 用戶。',
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
                const Text(
                  '感謝您的支持！',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '您目前擁有 Garage Pro 的所有權限。',
                  style: TextStyle(color: AppTheme.systemGray, fontSize: 14),
                ),
              ],
            ),
          );
        }

        if (state.offerings.isEmpty) {
          return const Center(
            child: Text(
              '目前沒有可選的方案',
              style: TextStyle(color: AppTheme.systemGray),
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
                          child: const Text(
                            '最佳選擇',
                            style: TextStyle(
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
        return '按月訂閱';
      case PackageType.annual:
        return '年度訂閱';
      default:
        return p.storeProduct.title;
    }
  }

  String _getPackageDescription(Package p) {
    switch (p.packageType) {
      case PackageType.monthly:
        return '隨時取消，無壓力享受 Pro。';
      case PackageType.annual:
        return '一年長效，價格更優惠。';
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
        child: const Text(
          '還原購買 (Restore Purchases)',
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
