import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realestate/models/user.dart';

class UserDetailPage extends StatefulWidget {
  final UserModel user;

  UserDetailPage({required this.user});

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late UserModel currentUser;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  Future<void> _togglePremiumStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'isPremium': !currentUser.isPremium});

      setState(() {
        currentUser = UserModel(
          uid: currentUser.uid,
          email: currentUser.email,
          name: currentUser.name,
          password: currentUser.password,
          address: currentUser.address,
          phoneNumber: currentUser.phoneNumber,
          isPremium: !currentUser.isPremium,
          isDeleted: currentUser.isDeleted,
          savedProperties: currentUser.savedProperties,
          myProperties: currentUser.myProperties,
          transactions: currentUser.transactions,
          bankingInfo: currentUser.bankingInfo,
          profilePicture: currentUser.profilePicture,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Premium status ${currentUser.isPremium ? 'activated' : 'deactivated'}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating premium status'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleAccountStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'isDeleted': !currentUser.isDeleted});

      setState(() {
        currentUser = UserModel(
          uid: currentUser.uid,
          email: currentUser.email,
          name: currentUser.name,
          password: currentUser.password,
          address: currentUser.address,
          phoneNumber: currentUser.phoneNumber,
          isPremium: currentUser.isPremium,
          isDeleted: !currentUser.isDeleted,
          savedProperties: currentUser.savedProperties,
          myProperties: currentUser.myProperties,
          transactions: currentUser.transactions,
          bankingInfo: currentUser.bankingInfo,
          profilePicture: currentUser.profilePicture,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account ${currentUser.isDeleted ? 'deactivated' : 'activated'}'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating account status'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _permanentDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Permanent Delete', style: theme.textTheme.titleMedium),
          content: Text(
            'Are you sure you want to permanently delete this user? This action cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: theme.textTheme.bodyMedium),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete Permanently'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User permanently deleted'),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.pop(context);
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Details',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// User Profile Card
            Card(
              elevation: 4,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: currentUser.profilePicture != null
                          ? NetworkImage(currentUser.profilePicture!)
                          : null,
                      child: currentUser.profilePicture == null
                          ? Icon(Icons.person, size: 50, color: Colors.blue[800])
                          : null,
                    ),
                    SizedBox(height: 16),
                    Text(
                      currentUser.name,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      currentUser.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatusChip(
                          currentUser.isPremium ? 'Premium' : 'Regular',
                          currentUser.isPremium ? Colors.orange : Colors.blue,
                          currentUser.isPremium ? Icons.star : Icons.person,
                        ),
                        _buildStatusChip(
                          currentUser.isDeleted ? 'Inactive' : 'Active',
                          currentUser.isDeleted ? Colors.red : Colors.green,
                          currentUser.isDeleted ? Icons.block : Icons.check_circle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            /// User Info Card
            Card(
              elevation: 4,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow('Phone', currentUser.phoneNumber ?? 'Not provided', theme),
                    _buildInfoRow('Address', currentUser.address ?? 'Not provided', theme),
                    _buildInfoRow('Properties Owned', currentUser.myProperties.length.toString(), theme),
                    _buildInfoRow('Saved Properties', currentUser.savedProperties.length.toString(), theme),
                    _buildInfoRow('Transactions', currentUser.transactions.length.toString(), theme),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            /// Admin Actions
            Text(
              'Admin Actions',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            /// Premium Toggle Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _togglePremiumStatus,
                icon: Icon(currentUser.isPremium ? Icons.star_border : Icons.star),
                label: Text(currentUser.isPremium ? 'Remove Premium' : 'Make Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 12),

            /// Account Status Toggle Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _toggleAccountStatus,
                icon: Icon(currentUser.isDeleted ? Icons.check_circle : Icons.block),
                label: Text(currentUser.isDeleted ? 'Activate Account' : 'Deactivate Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentUser.isDeleted ? Colors.green : Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 12),

            /// Permanent Delete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _permanentDelete,
                icon: Icon(Icons.delete_forever),
                label: Text('Delete Permanently'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            if (isLoading) ...[
              SizedBox(height: 20),
              Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ':',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
