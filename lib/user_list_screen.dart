import 'package:flutter/material.dart';
import 'package:minhhai/auth_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await AuthService.getAllUsers();
    setState(() {
      users = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👥 Danh sách tài khoản"),
        backgroundColor: Colors.deepPurple,
      ),

      body: users.isEmpty
          ? const Center(
              child: Text("📭 Không có tài khoản nào"),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.person, size: 35),
                    title: Text("User: ${user['username']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${user['email']}"),
                        Text("Phone: ${user['phone']}"),
                        Text("Ngày tạo: ${user['created_at']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
