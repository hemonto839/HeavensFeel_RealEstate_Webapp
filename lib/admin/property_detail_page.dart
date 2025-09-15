import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realestate/models/property.dart';
import 'package:realestate/models/user.dart';

class PropertyDetailPage extends StatefulWidget {
  final PropertyModel property;

  PropertyDetailPage({required this.property});

  @override
  _PropertyDetailPageState createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  late PropertyModel currentProperty;
  bool isLoading = false;
  PropertyStatus? selectedStatus;
  UserModel? propertyOwner;
  bool ownerLoading = true;

  @override
  void initState() {
    super.initState();
    currentProperty = widget.property;
    selectedStatus = currentProperty.status;
    _fetchOwnerDetails();
  }

  Future<void> _fetchOwnerDetails() async {
    try {
      final ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentProperty.ownerId)
          .get();

      if (ownerDoc.exists) {
        setState(() {
          propertyOwner = UserModel.fromMap(ownerDoc.data()!);
          ownerLoading = false;
        });
      } else {
        setState(() {
          ownerLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        ownerLoading = false;
      });
    }
  }

  Future<void> _updatePropertyStatus() async {
    if (selectedStatus == null || selectedStatus == currentProperty.status) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(currentProperty.id)
          .update({
        'status': selectedStatus!.name,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      setState(() {
        currentProperty = currentProperty.copyWith(
          status: selectedStatus!,
          updatedAt: DateTime.now(),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property status updated successfully'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating property status'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteProperty() async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Property', style: theme.textTheme.titleMedium),
        content: Text(
          'Are you sure you want to delete this property? This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection('properties')
            .doc(currentProperty.id)
            .update({
          'isDeleted': true,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Property deleted successfully'), backgroundColor: Colors.red),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting property'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Property Details', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Images
            Container(
              height: 250,
              child: currentProperty.imageUrls.isNotEmpty
                  ? PageView.builder(
                      itemCount: currentProperty.imageUrls.length,
                      itemBuilder: (context, index) => Image.network(
                        currentProperty.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: theme.colorScheme.surfaceVariant,
                          child: Icon(Icons.home, size: 100, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Center(child: Icon(Icons.home, size: 100, color: theme.colorScheme.onSurfaceVariant)),
                    ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Title and Status
                Row(
                  children: [
                    Expanded(
                      child: Text(currentProperty.title,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    _buildStatusBadge(currentProperty.status),
                  ],
                ),
                SizedBox(height: 8),

                // Address
                Row(
                  children: [
                    Icon(Icons.location_on, color: theme.colorScheme.onSurfaceVariant, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text('${currentProperty.address}, ${currentProperty.city}, ${currentProperty.district}',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                  ],
                ),
                SizedBox(height: 16),

                // Price / Type / Listing cards
                Row(
                  children: [
                    Expanded(child: _buildInfoCard('Price', '\$${currentProperty.price?.toStringAsFixed(0) ?? currentProperty.rentPrice?.toStringAsFixed(0) ?? 'N/A'}', Colors.green)),
                    SizedBox(width: 12),
                    Expanded(child: _buildInfoCard('Type', currentProperty.propertyType.name.toUpperCase(), Colors.blue)),
                    SizedBox(width: 12),
                    Expanded(child: _buildInfoCard('Listing', currentProperty.listingType.name.toUpperCase(), Colors.orange)),
                  ],
                ),
                SizedBox(height: 20),

                // Property Details
                _buildCard(theme, 'Property Details', [
                  _buildDetailRow('Square Feet', '${currentProperty.squareFeet.toStringAsFixed(0)} sq ft', theme),
                  if (currentProperty.bedrooms != null) _buildDetailRow('Bedrooms', currentProperty.bedrooms.toString(), theme),
                  if (currentProperty.bathrooms != null) _buildDetailRow('Bathrooms', currentProperty.bathrooms.toString(), theme),
                  if (currentProperty.kitchen != null) _buildDetailRow('Kitchen', currentProperty.kitchen.toString(), theme),
                  if (currentProperty.balcony != null) _buildDetailRow('Balcony', currentProperty.balcony.toString(), theme),
                  if (currentProperty.yearBuilt != null) _buildDetailRow('Year Built', currentProperty.yearBuilt.toString(), theme),
                  _buildDetailRow('Division', currentProperty.division, theme),
                  _buildDetailRow('District', currentProperty.district, theme),
                  _buildDetailRow('Sub District', currentProperty.subDistrict, theme),
                  _buildDetailRow('Post Code', currentProperty.postcode, theme),
                ]),
                SizedBox(height: 20),

                // Description
                if (currentProperty.description?.isNotEmpty == true) ...[
                  _buildCard(theme, 'Description', [
                    Text(currentProperty.description!, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
                  ]),
                  SizedBox(height: 20),
                ],

                // Owner Info
                _buildCard(theme, 'Property Owner', [
                  if (ownerLoading)
                    Center(child: CircularProgressIndicator())
                  else if (propertyOwner != null)
                    Row(children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue[100],
                        backgroundImage: propertyOwner!.profilePicture != null ? NetworkImage(propertyOwner!.profilePicture!) : null,
                        child: propertyOwner!.profilePicture == null ? Icon(Icons.person, color: Colors.blue[800]) : null,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(propertyOwner!.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            if (propertyOwner!.isPremium)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.star, size: 12, color: Colors.orange[800]),
                                  SizedBox(width: 2),
                                  Text('Premium',
                                      style: TextStyle(color: Colors.orange[800], fontSize: 10, fontWeight: FontWeight.w600)),
                                ]),
                              ),
                          ]),
                          SizedBox(height: 4),
                          Text(propertyOwner!.email, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ]),
                      ),
                    ])
                  else
                    Text('Owner information not available',
                        style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant)),
                ]),
                SizedBox(height: 20),

                // Admin Actions
                Text('Admin Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 16),

                // Status update
                _buildCard(theme, 'Update Property Status', [
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<PropertyStatus>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: PropertyStatus.values.map((status) =>
                          DropdownMenuItem(value: status, child: Text(status.name.toUpperCase()))).toList(),
                        onChanged: (value) => setState(() => selectedStatus = value),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: (isLoading || selectedStatus == currentProperty.status) ? null : _updatePropertyStatus,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: Text('Update'),
                    ),
                  ]),
                ]),
                SizedBox(height: 16),

                // Delete Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.delete),
                    label: Text('Delete Property'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(vertical: 15)),
                    onPressed: isLoading ? null : _deleteProperty,
                  ),
                ),
                if (isLoading) ...[SizedBox(height: 20), Center(child: CircularProgressIndicator())],
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, String title, List<Widget> children) {
    return Card(
      elevation: 3,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ...children,
        ]),
      ),
    );
  }

  Widget _buildStatusBadge(PropertyStatus status) {
    Color color;
    switch (status) {
      case PropertyStatus.active: color = Colors.green; break;
      case PropertyStatus.pending: color = Colors.orange; break;
      case PropertyStatus.sold: color = Colors.red; break;
      case PropertyStatus.rented: color = Colors.blue; break;
      case PropertyStatus.inactive: color = Colors.grey; break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(width: 120, child: Text('$label:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ]),
    );
  }
}