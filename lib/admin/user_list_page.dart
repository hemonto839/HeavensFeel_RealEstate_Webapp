import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realestate/admin/user_details.dart';
import 'package:realestate/models/user.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> allUsers = [];
  List<UserModel> premiumUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isDeleted', isEqualTo: false)
          .orderBy('name')
          .get();

      List<UserModel> users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      setState(() {
        allUsers = users;
        premiumUsers = users.where((user) => user.isPremium).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Management',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Users (${allUsers.length})'),
            Tab(text: 'Premium Users (${premiumUsers.length})'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(allUsers, theme),
                _buildUserList(premiumUsers, theme),
              ],
            ),
    );
  }

  Widget _buildUserList(List<UserModel> users, ThemeData theme) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.4)),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: _fetchUsers,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            elevation: 3,
            color: theme.cardColor,
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue[100],
                backgroundImage: user.profilePicture != null 
                    ? NetworkImage(user.profilePicture!) 
                    : null,
                child: user.profilePicture == null 
                    ? Icon(Icons.person, color: Colors.blue[800])
                    : null,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (user.isPremium)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.orange[800]),
                          SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        '${user.myProperties.length} Properties',
                        Colors.green, // hardcoded branding
                        theme,
                      ),
                      SizedBox(width: 8),
                      _buildInfoChip(
                        '${user.savedProperties.length} Saved',
                        Colors.blue, // hardcoded branding
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color?.withOpacity(0.5)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailPage(user: user),
                  ),
                ).then((_) => _fetchUsers());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}