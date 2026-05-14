import 'package:app/services/api_service.dart';
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
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void promoteUser(User user) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Promote User"),
        content: Text("Make ${user.name} an ADMIN?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiClient.makeAdmin(user.id, widget.token);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User promoted")));
        fetchUsers(); // refresh
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to promote")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBar(title: Text("")),
            body: Center(child: CircularProgressIndicator()),
          )
        : hasError
        ? RefreshIndicator(
            onRefresh: ()=> fetchUsers(),
            child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 150),
                        Center(child: Icon(Icons.error_outline, size: 50)),
                        SizedBox(height: 10),
                        Center(child: Text("Failed to load data")),
                        Center(child: Text("Pull down to refresh")),
                      ],
                    ),
          )
        : Scaffold(
            appBar: AppBar(title: Text("Make Admin")),
            body: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(user.role),
                        SizedBox(width: 10),
                        if (user.role != "ADMIN" && user.role!= "SUPER_ADMIN")
                          ElevatedButton(
                            onPressed: () => promoteUser(user),
                            child: Text("Make Admin"),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}
