import 'package:app/core/app_theme.dart';
import 'package:flutter/material.dart';

class AppErrorView extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const AppErrorView({
    super.key,
    this.title = "डेटा लोड करने में समस्या हुई",
    this.message = "कृपया इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें",
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 0 ? constraints.maxHeight : 250,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.errorLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 32,
                        color: AppTheme.errorRed,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'TiroDevanagariHindi',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'TiroDevanagariHindi',
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    if (onRetry != null) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text("पुनः प्रयास करें"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryNavy,
                          side: const BorderSide(color: AppTheme.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
