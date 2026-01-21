import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:garage/theme/themed_status_bar.dart';
import 'package:garage/router/app_router.dart';
import 'package:url_launcher/url_launcher.dart';

class StaticContentPage extends StatelessWidget {
  final String title;
  final String markdownContent;

  const StaticContentPage({
    super.key,
    required this.title,
    required this.markdownContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ThemedStatusBar(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.safePop(),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Markdown(
          data: markdownContent,
          onTapLink: (text, href, title) async {
            if (href != null) {
              final url = Uri.parse(href);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            }
          },
          styleSheet: MarkdownStyleSheet(
            p: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            h1: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            h2: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              height: 2.0,
            ),
            h3: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
            listBullet: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          padding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
