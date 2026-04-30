import 'package:app/services/profile_service.dart';
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

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      setState(() {
        isLoading = true;
      });
      final result = await _service.getProfile();
      setState(() {
        userDetails = result;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("प्रोफ़ाइल")),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : userDetails.isEmpty
                ? const Center(child: Text("Could not fetch details"))
                : RefreshIndicator(
                    onRefresh: () => loadProfile(),
                    child: Card(
                      child: ListTile(
                        title: Text(userDetails["name"]),
                        subtitle: Text(userDetails["email"]),
                        trailing: userDetails["role"] == "SUPER_ADMIN"
                            ? Text("गुरुदेव")
                            : userDetails["role"] == "ADMIN"
                            ? Text("परिकर")
                            : userDetails["role"] == "PREMIUM"
                            ? Text("शरणागत ")
                            : Text(""),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
