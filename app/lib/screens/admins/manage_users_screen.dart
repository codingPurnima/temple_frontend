import 'package:app/core/app_theme.dart';
import 'package:app/services/api_service.dart';
import 'package:app/widgets/state_widgets/app_empty.dart';
import 'package:app/widgets/state_widgets/app_error.dart';
import 'package:app/widgets/state_widgets/app_loading.dart';
import 'package:app/widgets/user_model.dart';
import 'package:flutter/material.dart';

class ManageUsersScreen extends StatefulWidget {
  final String token;

  const ManageUsersScreen({super.key, required this.token});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<User> users = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      setState(() {
        hasError = false;
      });
      final data = await ApiClient.getUsers(widget.token);
      if (!mounted) return;
      setState(() {
        users = data;
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

  void promoteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("प्रशासक बनाएं / Promote User"),
        content: Text("क्या आप '${user.name}' को व्यवस्थापक (ADMIN) बनाना चाहते हैं?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("रद्द करें / Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.saffronAccent,
            ),
            child: const Text("हाँ / Confirm"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiClient.makeAdmin(user.id, widget.token);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${user.name} को प्रशासक बना दिया गया है"),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        fetchUsers();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("प्रशासक बनाने में विफल रहा। पुन: प्रयास करें।"),
          ),
        );
      }
    }
  }

  Widget _buildRoleBadge(String role) {
    final isAdmin = role == "ADMIN" || role == "SUPER_ADMIN";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin
            ? AppTheme.saffronAccent.withValues(alpha: 0.12)
            : AppTheme.cardBorder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAdmin
              ? AppTheme.saffronAccent.withValues(alpha: 0.3)
              : AppTheme.cardBorder,
        ),
      ),
      child: Text(
        isAdmin ? "प्रशासक ($role)" : "भक्त ($role)",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isAdmin ? AppTheme.saffronAccent : AppTheme.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = const AppLoadingView(message: "उपयोगकर्ता सूची लोड हो रही है...");
    } else if (hasError) {
      content = AppErrorView(
        message: "उपयोगकर्ता सूची लोड करने में त्रुटि हुई",
        onRetry: fetchUsers,
      );
    } else if (users.isEmpty) {
      content = AppEmptyView(
        title: "कोई उपयोगकर्ता नहीं मिला",
        subtitle: "सिस्टम में कोई अन्य उपयोगकर्ता उपलब्ध नहीं है",
        onRefresh: fetchUsers,
      );
    } else {
      content = RefreshIndicator(
        onRefresh: fetchUsers,
        color: AppTheme.saffronAccent,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final canPromote = user.role != "ADMIN" && user.role != "SUPER_ADMIN";

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.cardBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.08),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
                          style: const TextStyle(
                            fontFamily: 'TiroDevanagariHindi',
                            color: AppTheme.primaryNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontFamily: 'TiroDevanagariHindi',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildRoleBadge(user.role),
                          ],
                        ),
                      ),
                      if (canPromote)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: OutlinedButton(
                            onPressed: () => promoteUser(user),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.saffronAccent,
                              side: const BorderSide(color: AppTheme.saffronAccent),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "प्रशासक बनाएं\nMake Admin",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: const Text("उपयोगकर्ता प्रबंधन / Manage Users"),
      ),
      body: content,
    );
  }
}
