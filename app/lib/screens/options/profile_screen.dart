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
                    child: Center(
                      child: Container(
                        height: 450,
                        width: 250,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(232, 220, 230, 241),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [                              
                                // Top content (can expand if needed)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userDetails["name"],
                                      style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(userDetails["email"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),),
                                    const SizedBox(height: 8,),
                                    Text("1234567890", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),), //temp mob no.
                                  ],
                                ),
                                // Bottom role section
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    userDetails["role"] == "SUPER_ADMIN"
                                        ? "गुरुदेव"
                                        : userDetails["role"] == "ADMIN"
                                            ? "परिकर"
                                            : userDetails["role"] == "PREMIUM"
                                                ? "शरणागत"
                                                : "",
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                     ),
                    ),
          ),
        ],
      ),
    );
  }
}
