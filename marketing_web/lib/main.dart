import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// If you see a font loading error, try restarting the app.
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const GarageLandingApp());
}

class GarageLandingApp extends StatelessWidget {
  const GarageLandingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage - Vehicle Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE53935), // Red 600
        scaffoldBackgroundColor: const Color(0xFF050505), // Almost Black
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentImageIndex = 0;
  final List<String> _images = [
    'assets/screenshots/app_preview_1.png',
    'assets/screenshots/app_preview_2.png',
  ];

  @override
  void initState() {
    super.initState();
    _startImageTimer();
  }

  void _startImageTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _images.length;
        });
        _startImageTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Grid Background
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          // Content
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeader(context),
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 60,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 900) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: _buildPhoneMockup(context)),
                                const SizedBox(width: 60),
                                Expanded(child: _buildDownloadSection(context)),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _buildDownloadSection(context, centered: true),
                                const SizedBox(height: 60),
                                _buildPhoneMockup(context),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      width: double.infinity,
      child: Row(
        children: [
          Icon(Icons.garage_rounded, color: const Color(0xFFE53935), size: 32),
          const SizedBox(width: 12),
          Text(
            'GARAGE',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterLink('隱私政策&開源授權', () {
                launchUrl(
                  Uri.parse(
                    'https://drakehuang81.github.io/garage-landing/privacy.html',
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2026 Garage. All rights reserved.',
            style: GoogleFonts.notoSansTc(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: GoogleFonts.notoSansTc(
            color: Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneMockup(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          // Removed phone bezel/frame styling
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Screen Image with Animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: Image.asset(
                  _images[_currentImageIndex],
                  key: ValueKey<String>(_images[_currentImageIndex]),
                  width: 300,
                  fit: BoxFit
                      .contain, // Ensures dynamic height based on aspect ratio
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 300,
                      height: 600, // Fallback height
                      color: const Color(0xFF1E1E1E),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white24,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadSection(BuildContext context, {bool centered = false}) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '隨時隨地掌握車況，\n不論時間和地點',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.notoSansTc(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: const Color(0xFFF5F5F5),
          ),
        ),
        const SizedBox(height: 48),
        _buildStoreBadge(
          icon: Icons.apple,
          subtitle: 'Download on the',
          title: 'App Store',
          isApple: true,
        ),
        const SizedBox(height: 16),
        _buildStoreBadge(
          icon: Icons.android,
          subtitle: 'GET IT ON',
          title: 'Google Play',
          isApple: false,
        ),
      ],
    );
  }

  Widget _buildStoreBadge({
    required IconData icon,
    required String subtitle,
    required String title,
    required bool isApple,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isApple
                  ? Colors.white
                  : const Color(0xFF3DDC84), // Android Green or White
              size: 32,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    const double spacing = 40.0;

    // Vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
