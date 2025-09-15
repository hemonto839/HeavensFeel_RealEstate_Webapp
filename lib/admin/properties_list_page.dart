import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realestate/models/property.dart';
import 'property_detail_page.dart';

class PropertiesListPage extends StatefulWidget {
  @override
  _PropertiesListPageState createState() => _PropertiesListPageState();
}

class _PropertiesListPageState extends State<PropertiesListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<PropertyModel>> propertiesByStatus = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('properties')
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      List<PropertyModel> properties = snapshot.docs
          .map((doc) => PropertyModel.fromMap(doc.data()))
          .toList();

      Map<String, List<PropertyModel>> groupedProperties = {
        'active': [],
        'pending': [],
        'sold': [],
        'rented': [],
        'inactive': [],
      };

      for (var property in properties) {
        groupedProperties[property.status.name]?.add(property);
      }

      setState(() {
        propertiesByStatus = groupedProperties;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching properties: $e');
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
          'Properties Management',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'Active (${propertiesByStatus['active']?.length ?? 0})'),
            Tab(text: 'Pending (${propertiesByStatus['pending']?.length ?? 0})'),
            Tab(text: 'Sold (${propertiesByStatus['sold']?.length ?? 0})'),
            Tab(text: 'Rented (${propertiesByStatus['rented']?.length ?? 0})'),
            Tab(text: 'Inactive (${propertiesByStatus['inactive']?.length ?? 0})'),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPropertyList(propertiesByStatus['active'] ?? [], theme),
                _buildPropertyList(propertiesByStatus['pending'] ?? [], theme),
                _buildPropertyList(propertiesByStatus['sold'] ?? [], theme),
                _buildPropertyList(propertiesByStatus['rented'] ?? [], theme),
                _buildPropertyList(propertiesByStatus['inactive'] ?? [], theme),
              ],
            ),
    );
  }

  Widget _buildPropertyList(List<PropertyModel> properties, ThemeData theme) {
    if (properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined,
                size: 64, color: theme.colorScheme.onSurface.withOpacity(0.4)),
            SizedBox(height: 16),
            Text(
              'No properties found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: _fetchProperties,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return Card(
            elevation: 3,
            color: theme.cardColor,
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: theme.colorScheme.surfaceVariant,
                  child: property.imageUrls.isNotEmpty
                      ? Image.network(
                          property.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.home,
                                  color: theme.colorScheme.onSurfaceVariant),
                        )
                      : Icon(Icons.home,
                          color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              title: Text(
                property.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    '${property.address}, ${property.city}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      // 👇 Hardcoded colors for clarity
                      _buildPropertyChip(
                        property.propertyType.name.toUpperCase(),
                        Colors.blue,
                        theme,
                      ),
                      SizedBox(width: 8),
                      _buildPropertyChip(
                        property.listingType.name.toUpperCase(),
                        Colors.green,
                        theme,
                      ),
                      SizedBox(width: 8),
                      _buildPropertyChip(
                        '\$${property.price?.toStringAsFixed(0) ?? property.rentPrice?.toStringAsFixed(0) ?? 'N/A'}',
                        Colors.orange,
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
              trailing:
                  Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyDetailPage(property: property),
                  ),
                ).then((_) => _fetchProperties());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyChip(String text, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // light version of chosen hardcoded color
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
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