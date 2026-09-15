import 'package:app/core/app_theme.dart';
import 'package:app/services/profile_service.dart';
import 'package:app/widgets/state_widgets/app_error.dart';
import 'package:app/widgets/state_widgets/app_loading.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _service = ProfileService();

  bool isLoading = true;
  Map<String, dynamic> userDetails = {};
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });
      final result = await _service.getProfile();
      if (!mounted) return;
      setState(() {
        userDetails = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  String _getRoleDisplayName(String? role) {
    if (role == "SUPER_ADMIN") return "गुरुदेव";
    if (role == "ADMIN") return "परिकर";
    if (role == "PREMIUM" || role == "PREMIUM_USER") return "शरणागत";
    return "भक्त (Devotee)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(title: const Text("भक्त प्रोफ़ाइल")),
      body: isLoading
          ? const AppLoadingView(message: "विवरण लोड हो रहा है...")
          : hasError || userDetails.isEmpty
          ? RefreshIndicator(
              onRefresh: loadProfile,
              child: AppErrorView(
                title: "प्रोफ़ाइल विवरण लोड नहीं हो सका",
                onRetry: loadProfile,
              ),
            )
          : RefreshIndicator(
              onRefresh: loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppTheme.cardBorder,
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0E000000),
                            blurRadius: 20,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Decorative Header Bar
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryNavy,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.warmGold,
                                  width: 2.5,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "॥ भक्तिपथ परिचय पत्र ॥",
                              style: TextStyle(
                                fontFamily: 'TiroDevanagariHindi',
                                color: AppTheme.warmGoldLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Devotee Avatar
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.saffronLight,
                                    border: Border.all(
                                      color: AppTheme.warmGold,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    (userDetails["name"] != null &&
                                            userDetails["name"]
                                                .toString()
                                                .isNotEmpty)
                                        ? userDetails["name"]
                                              .toString()
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : "भ",
                                    style: const TextStyle(
                                      fontFamily: 'TiroDevanagariHindi',
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.saffronAccent,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Name
                                Text(
                                  userDetails["name"] ?? "",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'TiroDevanagariHindi',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Email
                                Text(
                                  userDetails["email"] ?? "",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),

                                const SizedBox(height: 20),
                                const Divider(
                                  color: AppTheme.cardBorder,
                                  height: 1,
                                ),
                                const SizedBox(height: 20),

                                // Role Seal
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.saffronLight,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: AppTheme.warmGoldLight,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: AppTheme.saffronAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _getRoleDisplayName(
                                          userDetails["role"],
                                        ),
                                        style: const TextStyle(
                                          fontFamily: 'TiroDevanagariHindi',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.saffronAccent,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
