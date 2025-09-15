import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 for logout
import 'user_list_page.dart';
import 'properties_list_page.dart';

class AdminHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme; // 👈 Added theme toggle callback
  final ThemeMode? themeMode;

  const AdminHomePage({Key? key, required this.onToggleTheme, this.themeMode}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int totalUsers = 0;
  int totalProperties = 0;
  int activeProperties = 0;
  int premiumUsers = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isDeleted', isEqualTo: false)
          .get();

      final premiumUsersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isDeleted', isEqualTo: false)
          .where('isPremium', isEqualTo: true)
          .get();

      final propertiesSnapshot = await FirebaseFirestore.instance
          .collection('properties')
          .where('isDeleted', isEqualTo: false)
          .get();

      final activePropertiesSnapshot = await FirebaseFirestore.instance
          .collection('properties')
          .where('isDeleted', isEqualTo: false)
          .where('status', isEqualTo: 'active')
          .get();

      setState(() {
        totalUsers = usersSnapshot.docs.length;
        premiumUsers = premiumUsersSnapshot.docs.length;
        totalProperties = propertiesSnapshot.docs.length;
        activeProperties = activePropertiesSnapshot.docs.length;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching dashboard data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Future<void> _logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/admin-signin'); // Back to AdminSignInPage
  } catch (e) {
    print("Logout failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logout failed. Please try again.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: "Toggle Theme",
            onPressed: widget.onToggleTheme, // 👈 Calls callback from main
            icon: Icon(
              isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
              color: Colors.white,
            ),
          ),
          IconButton(
            tooltip: "Logout",
            icon: Icon(Icons.logout,color: Colors.white,),
            onPressed: () => _logout(context), // 👈 Firebase logout
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Admin Panel',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          'Total Users',
                          totalUsers.toString(),
                          Icons.people,
                          theme.colorScheme.primary,
                          theme,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildStatsCard(
                          'Premium Users',
                          premiumUsers.toString(),
                          Icons.star,
                          theme.colorScheme.secondary,
                          theme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          'Total Properties',
                          totalProperties.toString(),
                          Icons.home,
                          theme.colorScheme.tertiary,
                          theme,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: _buildStatsCard(
                          'Active Properties',
                          activeProperties.toString(),
                          Icons.check_circle,
                          theme.colorScheme.secondaryContainer,
                          theme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  // Navigation Cards
                  Text(
                    'Management',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  SizedBox(height: 20),

                  _buildNavigationCard(
                    'Manage Users',
                    'View and manage all users',
                    Icons.people_outline,
                    theme.colorScheme.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserListPage()),
                    ),
                    theme,
                  ),
                  SizedBox(height: 15),

                  _buildNavigationCard(
                    'Manage Properties',
                    'View and manage all properties',
                    Icons.home_outlined,
                    theme.colorScheme.tertiary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PropertiesListPage()),
                    ),
                    theme,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard(
      String title, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 30),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color?.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}