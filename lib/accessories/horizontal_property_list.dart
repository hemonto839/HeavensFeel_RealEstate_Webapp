import 'package:flutter/material.dart';
import 'package:realestate/accessories/property_card.dart';
import 'package:realestate/models/property.dart';
import 'package:realestate/pages/property_details/property_detail_page.dart';
import 'package:realestate/pages/property_details/property_page_show.dart';
import 'package:realestate/services/firebase_properties.dart';

class HorizontalPropertySection extends StatefulWidget {
  final String title;
  final String subtitle;
  final PropertyPageType pageType;
  final Function(PropertyModel)? onCardTap;
  final double? sidePadding;
  final bool isWide;
  const HorizontalPropertySection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pageType,
    this.onCardTap,
    this.sidePadding = 100,
    required this.isWide,
  });

  @override
  State<HorizontalPropertySection> createState() =>
      _HorizontalPropertySectionState();
}

class _HorizontalPropertySectionState extends State<HorizontalPropertySection> {
  final FirebaseProperties _firebaseProperties = FirebaseProperties();
  late Future<List<PropertyModel>> _propertiesFuture;

  final ScrollController _scrollController = ScrollController();

  static const double cardWidth = 260;
  static const double cardSpacing = 12;
  // static const double sidePadding = 100;

  @override
  void initState() {
    super.initState();
    _propertiesFuture = _fetchProperties();
  }

  Future<List<PropertyModel>> _fetchProperties() {
    switch (widget.pageType) {
      case PropertyPageType.all:
        return _firebaseProperties.getAllProperties();
      case PropertyPageType.sale:
        return _firebaseProperties.getSaleProperties();
      case PropertyPageType.rent:
        return _firebaseProperties.getRentProperties();
      case PropertyPageType.saved:
        return _firebaseProperties.getSavedProperties();
      case PropertyPageType.myProperties:
        return _firebaseProperties.getMyProperties();
      case PropertyPageType.auction:
        return _firebaseProperties.getAuctionProperties();
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - (cardWidth + cardSpacing)).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + (cardWidth + cardSpacing)).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PropertyModel>>(
      future: _propertiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 300,
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        final properties = snapshot.data ?? [];
        if (properties.isEmpty) {
          return const SizedBox(
            height: 300,
            child: Center(child: Text("No properties found.")),
          );
        }

        return Column(
          crossAxisAlignment: widget.isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            // Section header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.sidePadding ?? 100, vertical: 8),
              child: Column(
                crossAxisAlignment: widget.isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: widget.isWide ? TextAlign.start : TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: widget.isWide ? TextAlign.start : TextAlign.center,
                    ),
                ],
              ),
            ),

            // Horizontal List with arrows
            SizedBox(
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: properties.length,
                    padding:
                        EdgeInsets.only(left: widget.sidePadding ?? 100, right: widget.sidePadding ?? 100),
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == properties.length - 1 ? 0 : cardSpacing,
                        ),
                        child: SizedBox(
                          width: cardWidth,
                          child: PropertyCard(
                            property: property,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyDetailsPage(property: property),
                                  ),
                                );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  // Left arrow button
                  Positioned(
                    left: 16,
                    child: CircleAvatar(
                      // backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        onPressed: _scrollLeft,
                      ),
                    ),
                  ),

                  // Right arrow button
                  Positioned(
                    right: 16,
                    child: CircleAvatar(
                      // backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: _scrollRight,
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}