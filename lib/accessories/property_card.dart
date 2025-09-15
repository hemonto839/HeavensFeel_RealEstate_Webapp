// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:realestate/models/property.dart';

// class PropertyCard extends StatefulWidget {
//   final PropertyModel property;
//   final VoidCallback? onTap;

//   const PropertyCard({super.key, required this.property, this.onTap});

//   @override
//   State<PropertyCard> createState() => _PropertyCardState();
// }

// class _PropertyCardState extends State<PropertyCard>
//     with TickerProviderStateMixin {
//   bool isFavorite = false;
//   bool isLoading = false;
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _checkIfFavorite();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   // Check if already favorite
//   Future<void> _checkIfFavorite() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//       if (userDoc.exists) {
//         final userData = userDoc.data() as Map<String, dynamic>;
//         final savedProperties = List<String>.from(
//           userData['savedProperties'] ?? [],
//         );

//         if (mounted) {
//           setState(() {
//             isFavorite = savedProperties.contains(widget.property.id);
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error checking favorite: $e');
//     }
//   }

//   // Toggle favorite
//   Future<void> _toggleFavorite() async {
//     final user = _auth.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please login first'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }

//     if (isLoading) return;

//     setState(() => isLoading = true);

//     try {
//       final userRef = _firestore.collection('users').doc(user.uid);
//       final userDoc = await userRef.get();

//       if (userDoc.exists) {
//         final userData = userDoc.data() as Map<String, dynamic>;
//         List<String> savedProperties = List<String>.from(
//           userData['savedProperties'] ?? [],
//         );

//         if (isFavorite) {
//           savedProperties.remove(widget.property.id);
//           setState(() => isFavorite = false);
//         } else {
//           savedProperties.add(widget.property.id);
//           setState(() => isFavorite = true);
//         }

//         await userRef.update({'savedProperties': savedProperties});
//         _checkIfFavorite();
//       }
//     } catch (e) {
//       debugPrint('Error updating favorite: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // Time formatting
//   // time
//   String _getListedDateText() {
//     // if (widget.property.createdAt == null) return '';

//     final date = widget.property.createdAt is Timestamp
//         ? (widget.property.createdAt as Timestamp).toDate()
//         : widget.property.createdAt;

//     final now = DateTime.now();
//     final diff = now.difference(date);

//     if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
//     if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
//     if (diff.inHours < 24) return "${diff.inHours}h ago";
//     if (diff.inDays == 1) return "Yesterday";
//     if (diff.inDays < 7) return "${diff.inDays} days ago";

//     return DateFormat('MMM dd, yyyy').format(date);
//   }

//   String _getPropertyTypeText() {
//     switch (widget.property.propertyType) {
//       case PropertyType.house:
//         return 'House';
//       case PropertyType.apartment:
//         return 'Apartment';
//       case PropertyType.plot:
//         return 'Plot';
//     }
//   }

//   String _getListingTypeText() {
//     switch (widget.property.listingType) {
//       case ListingType.sale:
//         return 'For Sale';
//       case ListingType.rent:
//         return 'For Rent';
//       case ListingType.auction:
//         return 'Auction';
//     }
//   }

//   Color _getStatusColor() {
//     switch (widget.property.status) {
//       case PropertyStatus.active:
//         return Colors.green;
//       case PropertyStatus.pending:
//         return Colors.orange;
//       case PropertyStatus.sold:
//         return Colors.red;
//       case PropertyStatus.rented:
//         return Colors.blue;
//       case PropertyStatus.inactive:
//         return Colors.grey;
//     }
//   }

//   String _getStatusText() {
//     switch (widget.property.status) {
//       case PropertyStatus.active:
//         return "Active";
//       case PropertyStatus.pending:
//         return "Pending";
//       case PropertyStatus.sold:
//         return "Sold";
//       case PropertyStatus.rented:
//         return "Rented";
//       case PropertyStatus.inactive:
//         return "Inactive";
//     }
//   }

//   String _getPriceText() {
//     if (widget.property.listingType == ListingType.sale) {
//       return widget.property.price != null
//           ? "\$${NumberFormat('#,###').format(widget.property.price)}"
//           : 'Price on request';
//     } else {
//       return widget.property.rentPrice != null
//           ? "\$${NumberFormat('#,###').format(widget.property.rentPrice)}/mo"
//           : 'Rent on request';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final listedDateText = _getListedDateText();
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 600;

//     return GestureDetector(
//       onTapDown: (_) => _animationController.forward(),
//       onTapUp: (_) => _animationController.reverse(),
//       onTapCancel: () => _animationController.reverse(),
//       onTap: widget.onTap,
//       child: AnimatedBuilder(
//         animation: _scaleAnimation,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _scaleAnimation.value,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                     spreadRadius: 0,
//                   ),
//                 ],
//               ),
//               clipBehavior: Clip.antiAlias,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Image Section with overlays
//                   Expanded(
//                     flex: isSmallScreen ? 5 : 6,
//                     child: Stack(
//                       children: [
//                         // Main Image
//                         Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(color: Colors.grey[100]),
//                           child: widget.property.imageUrls.isNotEmpty
//                               ? Image.network(
//                                   widget.property.imageUrls[0],
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       color: Colors.grey[200],
//                                       child: const Icon(
//                                         Icons.home_outlined,
//                                         size: 40,
//                                         color: Colors.grey,
//                                       ),
//                                     );
//                                   },
//                                 )
//                               : Container(
//                                   color: Colors.grey[200],
//                                   child: const Icon(
//                                     Icons.home_outlined,
//                                     size: 40,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                         ),

//                         // Gradient overlay for better text visibility
//                         Positioned(
//                           bottom: 0,
//                           left: 0,
//                           right: 0,
//                           child: Container(
//                             height: 60,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                                 colors: [
//                                   Colors.transparent,
//                                   Colors.black.withOpacity(0.3),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),

//                         // Listing Type Badge
//                         Positioned(
//                           top: 8,
//                           left: 8,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color:
//                                   widget.property.listingType ==
//                                       ListingType.sale
//                                   ? Colors.blue
//                                   : widget.property.listingType ==
//                                         ListingType.rent
//                                   ? Colors.green
//                                   : Colors.orange,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               _getListingTypeText(),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),

//                         // Property Type Badge
//                         Positioned(
//                           top: 8,
//                           right: 40,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.black54,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               _getPropertyTypeText(),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 9,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),

//                         // Favorite Button
//                         Positioned(
//                           top: 6,
//                           right: 6,
//                           child: GestureDetector(
//                             onTap: _toggleFavorite,
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.9),
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 4,
//                                   ),
//                                 ],
//                               ),
//                               child: isLoading
//                                   ? SizedBox(
//                                       width: 14,
//                                       height: 14,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         color: Colors.grey[400],
//                                       ),
//                                     )
//                                   : Icon(
//                                       isFavorite
//                                           ? Icons.favorite
//                                           : Icons.favorite_border,
//                                       color: isFavorite
//                                           ? Colors.red
//                                           : Colors.grey[600],
//                                       size: 16,
//                                     ),
//                             ),
//                           ),
//                         ),

//                         // Image count indicator (if multiple images)
//                         if (widget.property.imageUrls.length > 1)
//                           Positioned(
//                             bottom: 8,
//                             right: 8,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 6,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.black54,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(
//                                     Icons.photo_library,
//                                     color: Colors.white,
//                                     size: 10,
//                                   ),
//                                   const SizedBox(width: 2),
//                                   Text(
//                                     '${widget.property.imageUrls.length}',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),

//                   // Content Section
//                   Expanded(
//                     flex: isSmallScreen ? 4 : 5,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Price and Status Row
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   _getPriceText(),
//                                   style: TextStyle(
//                                     fontSize: isSmallScreen ? 14 : 16,
//                                     fontWeight: FontWeight.bold,
//                                     color:
//                                         widget.property.listingType ==
//                                             ListingType.sale
//                                         ? Colors.green[700]
//                                         : Colors.blue[700],
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               Row(
//                                 children: [
//                                   Container(
//                                     width: 8,
//                                     height: 8,
//                                     decoration: BoxDecoration(
//                                       color: _getStatusColor(),
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     _getStatusText(),
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),

//                           // const SizedBox(height: 4),

//                           // // Title
//                           // Text(
//                           //   widget.property.title,
//                           //   style: TextStyle(
//                           //     fontSize: isSmallScreen ? 13 : 14,
//                           //     fontWeight: FontWeight.w600,
//                           //     color: Colors.black87,
//                           //     height: 1.2,
//                           //   ),
//                           //   maxLines: 2,
//                           //   overflow: TextOverflow.ellipsis,
//                           // ),

//                           const SizedBox(height: 6),

//                           // Location
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.location_on_outlined,
//                                 size: isSmallScreen ? 12 : 14,
//                                 color: Colors.grey[600],
//                               ),
//                               const SizedBox(width: 2),
//                               Expanded(
//                                 child: Text(
//                                   '${widget.property.city}, ${widget.property.district}',
//                                   style: TextStyle(
//                                     fontSize: isSmallScreen ? 11 : 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),

//                           const SizedBox(height: 6),

//                           // Property Features (Bedrooms, Bathrooms, etc.)
//                           if (widget.property.bedrooms != null ||
//                               widget.property.bathrooms != null)
//                             Row(
//                               children: [
//                                 if (widget.property.bedrooms != null) ...[
//                                   Icon(
//                                     Icons.bed_outlined,
//                                     size: isSmallScreen ? 12 : 14,
//                                     color: Colors.grey[600],
//                                   ),
//                                   const SizedBox(width: 2),
//                                   Flexible(
//                                     child: Text(
//                                       '${widget.property.bedrooms}',
//                                       style: TextStyle(
//                                         fontSize: isSmallScreen ? 10 : 11,
//                                         color: Colors.grey[700],
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                 ],
//                                 if (widget.property.bathrooms != null) ...[
//                                   Icon(
//                                     Icons.bathtub_outlined,
//                                     size: isSmallScreen ? 12 : 14,
//                                     color: Colors.grey[600],
//                                   ),
//                                   const SizedBox(width: 2),
//                                   Flexible(
//                                     child: Text(
//                                       '${widget.property.bathrooms}',
//                                       style: TextStyle(
//                                         fontSize: isSmallScreen ? 10 : 11,
//                                         color: Colors.grey[700],
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                 ],
//                                 // Square feet
//                                 Icon(
//                                   Icons.square_foot,
//                                   size: isSmallScreen ? 12 : 14,
//                                   color: Colors.grey[600],
//                                 ),
//                                 const SizedBox(width: 2),
//                                 Expanded(
//                                   child: Text(
//                                     '${NumberFormat('#,###').format(widget.property.squareFeet)} sq ft',
//                                     style: TextStyle(
//                                       fontSize: isSmallScreen ? 10 : 11,
//                                       color: Colors.grey[700],
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),

//                           const Spacer(),

//                           // Time and View Button
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 listedDateText,
//                                 style: TextStyle(
//                                   fontSize: isSmallScreen ? 9 : 10,
//                                   color: Colors.grey[500],
//                                   fontStyle: FontStyle.italic,
//                                 ),
//                               ),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 2,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(
//                                     color: Colors.blue.withOpacity(0.3),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   'View',
//                                   style: TextStyle(
//                                     fontSize: isSmallScreen ? 9 : 10,
//                                     color: Colors.blue[700],
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:realestate/models/property.dart';

class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final VoidCallback? onTap;

  const PropertyCard({super.key, required this.property, this.onTap});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard>
    with TickerProviderStateMixin {
  bool isFavorite = false;
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Check if already favorite
  Future<void> _checkIfFavorite() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final savedProperties = List<String>.from(
          userData['savedProperties'] ?? [],
        );
        if (mounted) {
          setState(() {
            isFavorite = savedProperties.contains(widget.property.id);
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking favorite: $e');
    }
  }

  // Toggle favorite
  Future<void> _toggleFavorite() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        List<String> savedProperties = List<String>.from(
          userData['savedProperties'] ?? [],
        );
        if (isFavorite) {
          savedProperties.remove(widget.property.id);
          setState(() => isFavorite = false);
        } else {
          savedProperties.add(widget.property.id);
          setState(() => isFavorite = true);
        }
        await userRef.update({'savedProperties': savedProperties});
        _checkIfFavorite();
      }
    } catch (e) {
      debugPrint('Error updating favorite: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Time formatting
  String _getListedDateText() {
    final date = widget.property.createdAt is Timestamp
        ? (widget.property.createdAt as Timestamp).toDate()
        : widget.property.createdAt;

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays} days ago";

    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _getPropertyTypeText() {
    switch (widget.property.propertyType) {
      case PropertyType.house:
        return 'House';
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.plot:
        return 'Plot';
    }
  }

  String _getListingTypeText() {
    switch (widget.property.listingType) {
      case ListingType.sale:
        return 'For Sale';
      case ListingType.rent:
        return 'For Rent';
      case ListingType.auction:
        return 'Auction';
    }
  }

  Color _getStatusColor() {
    switch (widget.property.status) {
      case PropertyStatus.active:
        return Colors.green;
      case PropertyStatus.pending:
        return Colors.orange;
      case PropertyStatus.sold:
        return Colors.red;
      case PropertyStatus.rented:
        return Colors.blue;
      case PropertyStatus.inactive:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (widget.property.status) {
      case PropertyStatus.active:
        return "Active";
      case PropertyStatus.pending:
        return "Pending";
      case PropertyStatus.sold:
        return "Sold";
      case PropertyStatus.rented:
        return "Rented";
      case PropertyStatus.inactive:
        return "Inactive";
    }
  }

  String _getPriceText() {
    if (widget.property.listingType == ListingType.sale) {
      return widget.property.price != null
          ? "\$${NumberFormat('#,###').format(widget.property.price)}"
          : 'Price on request';
    } else {
      return widget.property.rentPrice != null
          ? "\$${NumberFormat('#,###').format(widget.property.rentPrice)}/mo"
          : 'Rent on request';
    }
  }

  @override
  Widget build(BuildContext context) {
    final listedDateText = _getListedDateText();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface, // THEME surface background
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGE SECTION
                  Expanded(
                    flex: isSmallScreen ? 5 : 6,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: scheme.surfaceVariant,
                          child: widget.property.imageUrls.isNotEmpty
                              ? Image.network(
                                  widget.property.imageUrls[0],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: scheme.surfaceVariant,
                                    child: Icon(Icons.home_outlined,
                                        size: 40,
                                        color: scheme.onSurfaceVariant),
                                  ),
                                )
                              : Container(
                                  color: scheme.surfaceVariant,
                                  child: Icon(Icons.home_outlined,
                                      size: 40,
                                      color: scheme.onSurfaceVariant),
                                ),
                        ),
                        // Gradient Overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Listing Badge (sale/rent/auction colors unchanged)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.property.listingType ==
                                      ListingType.sale
                                  ? Colors.blue
                                  : widget.property.listingType ==
                                          ListingType.rent
                                      ? Colors.green
                                      : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getListingTypeText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // PropertyType Tag (dark overlay preserved)
                        Positioned(
                          top: 8,
                          right: 40,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getPropertyTypeText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // Favorite (unchanged)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: _toggleFavorite,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4)
                                ],
                              ),
                              child: isLoading
                                  ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  )
                                  : Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.red
                                        : scheme.onSurfaceVariant,
                                    size: 16,
                                  ),
                            ),
                          ),
                        ),
                        // Image count indicator (black overlay preserved)
                        if (widget.property.imageUrls.length > 1)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.photo_library,
                                      color: Colors.white, size: 10),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${widget.property.imageUrls.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // CONTENT SECTION
                  Expanded(
                    flex: isSmallScreen ? 4 : 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price & Status
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _getPriceText(),
                                      style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: widget.property.listingType ==
                                                  ListingType.sale
                                              ? Colors.green[700]
                                              : Colors.blue[700]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                          color: _getStatusColor(),
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getStatusText(),
                                      style: textTheme.bodyMedium,
                                    ),
                                  ])
                                ]),
                            const SizedBox(height: 6),
                            // Location
                            Row(children: [
                              Icon(Icons.location_on_outlined,
                                  size: isSmallScreen ? 12 : 14,
                                  color: scheme.onSurfaceVariant),
                              const SizedBox(width: 2),
                              Expanded(
                                  child: Text(
                                      '${widget.property.city}, ${widget.property.district}',
                                      style: textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1))
                            ]),
                            const SizedBox(height: 6),
                            // Features
                            if (widget.property.bedrooms != null ||
                                widget.property.bathrooms != null)
                              Row(children: [
                                if (widget.property.bedrooms != null) ...[
                                  Icon(Icons.bed_outlined,
                                      size: isSmallScreen ? 12 : 14,
                                      color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 2),
                                  Flexible(
                                      child: Text(
                                          '${widget.property.bedrooms}',
                                          style: textTheme.bodySmall?.copyWith(
                                              color: scheme.onSurface,
                                              fontWeight: FontWeight.w500))),
                                  const SizedBox(width: 8),
                                ],
                                if (widget.property.bathrooms != null) ...[
                                  Icon(Icons.bathtub_outlined,
                                      size: isSmallScreen ? 12 : 14,
                                      color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 2),
                                  Flexible(
                                      child: Text(
                                          '${widget.property.bathrooms}',
                                          style: textTheme.bodySmall?.copyWith(
                                              color: scheme.onSurface,
                                              fontWeight: FontWeight.w500))),
                                  const SizedBox(width: 8),
                                ],
                                Icon(Icons.square_foot,
                                    size: isSmallScreen ? 12 : 14,
                                    color: scheme.onSurfaceVariant),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    '${NumberFormat('#,###').format(widget.property.squareFeet)} sq ft',
                                    style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurface,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ]),
                            const Spacer(),
                            // Time + View Button
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(listedDateText,
                                      style: textTheme.bodySmall?.copyWith(
                                          fontSize:
                                              isSmallScreen ? 9 : 10,
                                          color: scheme.onSurfaceVariant,
                                          fontStyle: FontStyle.italic)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.blue
                                                .withOpacity(0.3))),
                                    child: Text('View',
                                        style: TextStyle(
                                            fontSize: isSmallScreen ? 9 : 10,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w600)),
                                  )
                                ])
                          ]),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}