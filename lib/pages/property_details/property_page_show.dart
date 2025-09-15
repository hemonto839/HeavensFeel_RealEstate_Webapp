import 'package:flutter/material.dart';
import 'package:realestate/accessories/property_card.dart';
import 'package:realestate/models/property.dart';
import 'package:realestate/pages/property_details/property_detail_page.dart';
import 'package:realestate/services/firebase_properties.dart';
import 'package:realestate/accessories/property_filter_widget.dart';

/*
  The Use of this:
      use it when you have to show some properties in
       different pages such as (myProperty, saveProperties, specific rent, specific for sale) 

*/

enum PropertyPageType {
  all,          // Show all properties
  sale,         // Show only properties for sale
  rent,         // Show only properties for rent
  saved,        // Show saved properties of current user
  myProperties, // Show properties listed by current user
  auction,   // handle later
}

class PropertyPageShow extends StatefulWidget {
   final PropertyPageType pageType;
  final List<PropertyModel>? searchResults; 

  const PropertyPageShow({
    super.key,
    required this.pageType,
    this.searchResults, 
  });


  @override
  State<PropertyPageShow> createState() => _PropertyPageShowState();
}

class _PropertyPageShowState extends State<PropertyPageShow> {
  final FirebaseProperties _firebaseProperties = FirebaseProperties();
  late Future<List<PropertyModel>> _propertiesFuture;

  PropertyFilter currentFilter = PropertyFilter();
  List<String> availableDistricts = [];
  List<PropertyModel> allProperties = [];

  @override
  void initState() {
    super.initState();

  if (widget.searchResults != null) {
    allProperties = widget.searchResults!;
    availableDistricts = allProperties
        .map((p) => p.district)
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    availableDistricts.sort();
    _propertiesFuture = Future.value(allProperties);
  } else {
    _propertiesFuture = _fetchProperties();
  }
  }

  Future<List<PropertyModel>> _fetchProperties() {
    Future<List<PropertyModel>> future;
    switch (widget.pageType) {
      case PropertyPageType.all:
        future = _firebaseProperties.getAllProperties();
        break;
      case PropertyPageType.sale:
        future = _firebaseProperties.getSaleProperties();
        break;
      case PropertyPageType.rent:
        future = _firebaseProperties.getRentProperties();
        break;
      case PropertyPageType.saved:
        future = _firebaseProperties.getSavedProperties();
        break;
      case PropertyPageType.myProperties:
        future = _firebaseProperties.getMyProperties();
        break;
      case PropertyPageType.auction:
        future = _firebaseProperties.getAuctionProperties();
        break;
    }

    return future.then((properties) {
      allProperties = properties;
      availableDistricts = properties
          .map((p) => p.district)
          .where((d) => d.isNotEmpty)
          .toSet()
          .toList();
      availableDistricts.sort();
      return currentFilter.applyFilter(properties);
    });
  }

  // Get responsive cross axis count based on screen width
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) return 5; // Large desktop
    if (screenWidth > 900) return 4;  // Desktop/tablet landscape
    if (screenWidth > 600) return 3;  // Tablet portrait
    if (screenWidth > 400) return 2;  // Large mobile
    return 1; // Small mobile
  }

  // Get responsive aspect ratio based on screen width
  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth > 900) return 0.75; // Desktop: taller cards
    if (screenWidth > 600) return 0.8;  // Tablet: slightly taller
    return 0.85; // Mobile: more square-ish for better readability
  }

  // double _getChildAspectRatio(double screenWidth) {
  //   if (screenWidth > 900) return 0.65; 
  //   if (screenWidth > 600) return 0.7;  
  //   return 0.75; 
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _getPageTitle(widget.pageType),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        // backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
       actions: [
  IconButton(
    icon: Stack(
      children: [
        const Icon(Icons.filter_list),
        if (currentFilter.hasActiveFilters)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    ),
    onPressed: () async {
      final newFilter = await PropertyFilterBottomSheet.show(
        context: context,
        currentFilter: currentFilter,
        availableDistricts: availableDistricts,
      );
      if (newFilter != null) {
        setState(() {
          currentFilter = newFilter;
          _propertiesFuture = Future.value(currentFilter.applyFilter(allProperties));
        });
      }
    },
  ),
],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _propertiesFuture = _fetchProperties();
          });
        },
        child: FutureBuilder<List<PropertyModel>>(
          future: _propertiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingGrid();
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _propertiesFuture = _fetchProperties();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            final properties = snapshot.data ?? [];
            if (properties.isEmpty) {
              return _buildEmptyState();
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final crossAxisCount = _getCrossAxisCount(screenWidth);
                final aspectRatio = _getChildAspectRatio(screenWidth);
                
                return CustomScrollView(
                  slivers: [
                    // Header with count
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getPageIcon(widget.pageType),
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${properties.length} Properties Found',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  _getPageSubtitle(widget.pageType),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Properties Grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: aspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final property = properties[index];
                            return PropertyCard(
                              property: property,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyDetailsPage(property: property),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: properties.length,
                        ),
                      ),
                    ),
                    
                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = _getCrossAxisCount(screenWidth);
        final aspectRatio = _getChildAspectRatio(screenWidth);
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: 8, // Show 8 skeleton cards
          itemBuilder: (context, index) => _buildSkeletonCard(),
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          // Content skeleton
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getEmptyStateIcon(widget.pageType),
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getEmptyStateTitle(widget.pageType),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateSubtitle(widget.pageType),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _propertiesFuture = _fetchProperties();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }


  String _getPageTitle(PropertyPageType type) {
    switch (type) {
      case PropertyPageType.all:
        return 'All Properties';
      case PropertyPageType.sale:
        return 'Properties for Sale';
      case PropertyPageType.rent:
        return 'Properties for Rent';
      case PropertyPageType.saved:
        return 'Saved Properties';
      case PropertyPageType.myProperties:
        return 'My Properties';
      case PropertyPageType.auction:
        return 'Properties for Auction';
    }
  }

  String _getPageSubtitle(PropertyPageType type) {
    switch (type) {
      case PropertyPageType.all:
        return 'Browse all available properties';
      case PropertyPageType.sale:
        return 'Properties available for purchase';
      case PropertyPageType.rent:
        return 'Properties available for rent';
      case PropertyPageType.saved:
        return 'Your favorite properties';
      case PropertyPageType.myProperties:
        return 'Properties you have listed';
      case PropertyPageType.auction:
        return 'Properties available for auction';
    }
  }

  IconData _getPageIcon(PropertyPageType type) {
    switch (type) {
      case PropertyPageType.all:
        return Icons.home_outlined;
      case PropertyPageType.sale:
        return Icons.attach_money;
      case PropertyPageType.rent:
        return Icons.key_outlined;
      case PropertyPageType.saved:
        return Icons.favorite_outline;
      case PropertyPageType.myProperties:
        return Icons.business_outlined;
      case PropertyPageType.auction:
        return Icons.gavel_outlined;
    }
  }

  IconData _getEmptyStateIcon(PropertyPageType type) {
    switch (type) {
      case PropertyPageType.all:
        return Icons.search_off;
      case PropertyPageType.sale:
        return Icons.home_work_outlined;
      case PropertyPageType.rent:
        return Icons.key_off_outlined;
      case PropertyPageType.saved:
        return Icons.favorite_border;
      case PropertyPageType.myProperties:
        return Icons.add_business_outlined;
      case PropertyPageType.auction:
        return Icons.gavel_outlined;
    }
  }

  String _getEmptyStateTitle(PropertyPageType type) {
    switch (type) {
      case PropertyPageType.all:
        return 'No Properties Found';
      case PropertyPageType.sale:
        return 'No Properties for Sale';
      case PropertyPageType.rent:
        return 'No Rental Properties';
      case PropertyPageType.saved:
        return 'No Saved Properties';
      case PropertyPageType.myProperties:
        return 'No Listed Properties';
      case PropertyPageType.auction:
        return 'No Properties for Auction';
    }
  }

  String _getEmptyStateSubtitle(PropertyPageType type) {
    switch (type) {
      case PropertyPageType.all:
        return 'Try adjusting your search criteria or check back later.';
      case PropertyPageType.sale:
        return 'No properties are currently available for sale.';
      case PropertyPageType.rent:
        return 'No rental properties are currently available.';
      case PropertyPageType.saved:
        return 'Start exploring properties and save your favorites.';
      case PropertyPageType.myProperties:
        return 'List your first property to get started.';
      case PropertyPageType.auction:
        return 'Start bidding on properties to participate in auctions.';
    }
  }
}