import 'package:flutter/material.dart';
import 'package:realestate/models/property.dart';

// Price sorting options
enum PriceSorting { none, lowToHigh, highToLow }

class PropertyFilter {
  final PriceSorting priceSorting;
  final String? selectedDistrict;
  final PropertyType? selectedPropertyType;

  PropertyFilter({
    this.priceSorting = PriceSorting.none,
    this.selectedDistrict,
    this.selectedPropertyType,
  });

  PropertyFilter copyWith({
    PriceSorting? priceSorting,
    String? selectedDistrict,
    PropertyType? selectedPropertyType,
    bool clearDistrict = false,
    bool clearPropertyType = false,
  }) {
    return PropertyFilter(
      priceSorting: priceSorting ?? this.priceSorting,
      selectedDistrict: clearDistrict ? null : (selectedDistrict ?? this.selectedDistrict),
      selectedPropertyType: clearPropertyType ? null : (selectedPropertyType ?? this.selectedPropertyType),
    );
  }

  // Method to apply filters to a list of properties
  List<PropertyModel> applyFilter(List<PropertyModel> properties) {
    List<PropertyModel> filteredProperties = List.from(properties);

    // Filter by district
    if (selectedDistrict != null && selectedDistrict!.isNotEmpty) {
      filteredProperties = filteredProperties
          .where((property) => property.district.toLowerCase() == selectedDistrict!.toLowerCase())
          .toList();
    }

    // Filter by property type
    if (selectedPropertyType != null) {
      filteredProperties = filteredProperties
          .where((property) => property.propertyType == selectedPropertyType)
          .toList();
    }

    // Sort by price
    if (priceSorting != PriceSorting.none) {
      filteredProperties.sort((a, b) {
        // Get price for sorting (use price or rentPrice based on listing type)
        double? priceA = a.listingType == ListingType.rent ? a.rentPrice : a.price;
        double? priceB = b.listingType == ListingType.rent ? b.rentPrice : b.price;

        // Handle null prices (put them at the end)
        if (priceA == null && priceB == null) return 0;
        if (priceA == null) return 1;
        if (priceB == null) return -1;

        if (priceSorting == PriceSorting.lowToHigh) {
          return priceA.compareTo(priceB);
        } else {
          return priceB.compareTo(priceA);
        }
      });
    }

    return filteredProperties;
  }

  // Check if any filters are active
  bool get hasActiveFilters {
    return priceSorting != PriceSorting.none ||
           selectedDistrict != null ||
           selectedPropertyType != null;
  }
}

class PropertyFilterWidget extends StatefulWidget {
  final PropertyFilter initialFilter;
  final Function(PropertyFilter) onFilterChanged;
  final List<String> availableDistricts;

  const PropertyFilterWidget({
    Key? key,
    required this.initialFilter,
    required this.onFilterChanged,
    required this.availableDistricts,
  }) : super(key: key);

  @override
  State<PropertyFilterWidget> createState() => _PropertyFilterWidgetState();
}

class _PropertyFilterWidgetState extends State<PropertyFilterWidget> {
  late PropertyFilter currentFilter;

  @override
  void initState() {
    super.initState();
    currentFilter = widget.initialFilter;
  }

  void _updateFilter(PropertyFilter newFilter) {
    setState(() {
      currentFilter = newFilter;
    });
    widget.onFilterChanged(newFilter);
  }

  String _getPropertyTypeDisplayName(PropertyType type) {
    switch (type) {
      case PropertyType.house:
        return 'House';
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.plot:
        return 'Plot';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        //color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (currentFilter.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    _updateFilter(PropertyFilter());
                  },
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const Divider(),
          
          // Price Sorting Section
          const Text(
            'Price Sorting',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              RadioListTile<PriceSorting>(
                title: const Text('Low to High'),
                value: PriceSorting.lowToHigh,
                groupValue: currentFilter.priceSorting,
                onChanged: (value) {
                  _updateFilter(currentFilter.copyWith(priceSorting: value));
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<PriceSorting>(
                title: const Text('High to Low'),
                value: PriceSorting.highToLow,
                groupValue: currentFilter.priceSorting,
                onChanged: (value) {
                  _updateFilter(currentFilter.copyWith(priceSorting: value));
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          
          if (currentFilter.priceSorting != PriceSorting.none)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  _updateFilter(currentFilter.copyWith(priceSorting: PriceSorting.none));
                },
                child: const Text('Clear Price Sort'),
              ),
            ),

          const SizedBox(height: 16),

          // District Selection
          const Text(
            'District',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: currentFilter.selectedDistrict,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select District',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Districts'),
              ),
              ...widget.availableDistricts.map((district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
            ],
            onChanged: (value) {
              _updateFilter(currentFilter.copyWith(
                selectedDistrict: value,
                clearDistrict: value == null,
              ));
            },
          ),

          const SizedBox(height: 16),

          // Property Type Selection
          const Text(
            'Property Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: PropertyType.values.map((type) {
              final isSelected = currentFilter.selectedPropertyType == type;
              return FilterChip(
                label: Text(_getPropertyTypeDisplayName(type)),
                selected: isSelected,
                onSelected: (selected) {
                  _updateFilter(
                    currentFilter.copyWith(
                      selectedPropertyType: selected ? type : null,
                      clearPropertyType: !selected,
                    ),
                  );
                },
                selectedColor: Colors.blue.shade100,
                checkmarkColor: Colors.blue.shade700,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Active Filters Summary (Optional)
          if (currentFilter.hasActiveFilters) ...[
            const Text(
              'Active Filters:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                if (currentFilter.priceSorting != PriceSorting.none)
                  Chip(
                    label: Text(
                      currentFilter.priceSorting == PriceSorting.lowToHigh
                          ? 'Price: Low to High'
                          : 'Price: High to Low',
                    ),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: const TextStyle(fontSize: 12),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                if (currentFilter.selectedDistrict != null)
                  Chip(
                    label: Text('District: ${currentFilter.selectedDistrict}'),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: const TextStyle(fontSize: 12),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                if (currentFilter.selectedPropertyType != null)
                  Chip(
                    label: Text('Type: ${_getPropertyTypeDisplayName(currentFilter.selectedPropertyType!)}'),
                    backgroundColor: Colors.orange.shade50,
                    labelStyle: const TextStyle(fontSize: 12),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Helper class to show filter as a bottom sheet
class PropertyFilterBottomSheet {
  static Future<PropertyFilter?> show({
    required BuildContext context,
    required PropertyFilter currentFilter,
    required List<String> availableDistricts,
  }) async {
    PropertyFilter? result;
    
    await showModalBottomSheet<PropertyFilter>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: PropertyFilterWidget(
                      initialFilter: currentFilter,
                      availableDistricts: availableDistricts,
                      onFilterChanged: (filter) {
                        result = filter;
                      },
                    ),
                  ),
                ),
                // Apply button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, result ?? currentFilter);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Apply Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    return result;
  }
}