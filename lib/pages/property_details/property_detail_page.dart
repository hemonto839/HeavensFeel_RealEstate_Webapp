import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong2/latlong.dart';
import 'package:realestate/models/property.dart';
import 'package:realestate/models/user.dart';
import 'package:realestate/pages/chat_page.dart';
import 'package:realestate/pages/property_details/bidding_page.dart';
import 'package:realestate/pages/sign_in.dart';
import 'package:realestate/services/firebase_user.dart';
import 'package:realestate/services/map_service.dart';

class PropertyDetailsPage extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailsPage({super.key, required this.property});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  UserModel? owner;
  bool isLoading = true;

final FirebaseAuth _auth = FirebaseAuth.instance;

// Get the current user


  // For image carousel
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _fetchOwner();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchOwner() async {
    final firebaseUser = FirebaseUser();
    UserModel? fetchedOwner =
        await firebaseUser.getUserById(widget.property.ownerId);
    setState(() {
      owner = fetchedOwner;
      isLoading = false;
    });
  }

  Widget _buildMapSection(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.property.latitude == null ||
        widget.property.longitude == null) {
      return const SizedBox.shrink(); // Don't show map if no coordinates
    }

    final location =
        LatLng(widget.property.latitude!, widget.property.longitude!);

    return _buildSectionCard(
      context,
      title: "Location",
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LocationService.showMap(location, zoom: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property.title,
            style: theme.textTheme.titleLarge
                ?.copyWith(color: theme.colorScheme.onPrimary)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(widget.property.imageUrls),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context,
                    title: "Property Overview",
                    child: _buildPropertyOverview(context),
                  ),
                  _buildSectionCard(
                    context,
                    title: "Specifications",
                    child: _buildSpecifications(context),
                  ),
                  _buildAddress(context),
                  _buildOwnerInfo(context),
                  _buildMapSection(context),

                  // if (widget.property.listingType == ListingType.auction) ...[
                  //   const SizedBox(height: 16),
                  //   Center(
                  //     child: ElevatedButton(
                  //       onPressed: () {
                  //         // Navigate to bidding page
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) =>
                  //                 BiddingPage(property: widget.property),
                  //           ),
                  //         );
                  //       },
                  //       child: const Text("Go to Bidding Page"),
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
        floatingActionButton: user != null &&
          widget.property.listingType == ListingType.auction
            ? FloatingActionButton.extended(
                // backgroundColor: theme.colorScheme.onPrimary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BiddingPage(property: widget.property),
                    ),
                  );
                },
                icon: const Icon(Icons.gavel),
                label: const Text("Bid"),
              )
            : null,
    );
  }

  // 🔹 Image Carousel
  Widget _buildImageCarousel(List<String> images) {
    void _scrollLeft() {
      if (currentIndex > 0) {
        currentIndex--;
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    void _scrollRight() {
      if (currentIndex < images.length - 1) {
        currentIndex++;
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    return SizedBox(
      height: 350,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, _) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, _, __) => const Icon(Icons.error),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              left: 16,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: _scrollLeft,
              ),
            ),
          if (images.length > 1)
            Positioned(
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white),
                onPressed: _scrollRight,
              ),
            ),
        ],
      ),
    );
  }

  //
  Widget _buildSectionCard(BuildContext context,
          {required String title, required Widget child}) =>
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      );

  // 🔹 Property Overview
  Widget _buildPropertyOverview(BuildContext context) {
    final property = widget.property;
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(property.description ?? "No description provided.",
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              _infoChip(context, "Listing", property.listingType.name),
              _infoChip(context, "Status", property.status.name),
              _infoChip(context, "Sq. Ft.", "${property.squareFeet}"),
              if (property.price != null)
                _infoChip(context, "Price",
                    "\$${property.price!.toStringAsFixed(2)}"),
              if (property.rentPrice != null)
                _infoChip(context, "Rent",
                    "\$${property.rentPrice!.toStringAsFixed(2)}"),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Specifications
  Widget _buildSpecifications(BuildContext context) {
    return Column(
      children: [
        if (widget.property.bedrooms != null)
          _specTile(context, "Bedrooms", widget.property.bedrooms.toString()),
        if (widget.property.bathrooms != null)
          _specTile(context, "Bathrooms", widget.property.bathrooms.toString()),
        if (widget.property.balcony != null)
          _specTile(context, "Balcony", widget.property.balcony.toString()),
        if (widget.property.kitchen != null)
          _specTile(context, "Kitchen", widget.property.kitchen.toString()),
        if (widget.property.yearBuilt != null)
          _specTile(context, "Year Built", widget.property.yearBuilt.toString()),
      ],
    );
  }

  // Address
  Widget _buildAddress(BuildContext context) {
    final p = widget.property;
    Theme.of(context);

    return _buildSectionCard(
      context,
      title: "Address",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddressRow(context, "Address", p.city),
          const SizedBox(height: 8),
          _buildAddressRow(context, "District", p.district),
          const SizedBox(height: 8),
          _buildAddressRow(context, "Subdistrict", p.subDistrict),
          const SizedBox(height: 8),
          _buildAddressRow(context, "Division", p.division),
          const SizedBox(height: 8),
          _buildAddressRow(context, "Country", p.country),
          const SizedBox(height: 8),
          _buildAddressRow(context, "Post Code", p.postcode),
        ],
      ),
    );
  }

  Widget _buildAddressRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : "N/A",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfo(BuildContext context) {
    final theme = Theme.of(context);
    final user = _auth.currentUser;

    if (owner == null) return const Text("Owner not found");

    return _buildSectionCard(
      context,
      title: "Listed By",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: owner!.profilePicture != null
                      ? NetworkImage(owner!.profilePicture!)
                      : null,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: owner!.profilePicture == null
                      ? Icon(Icons.person,
                          size: 30, color: theme.colorScheme.primary)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOwnerRow(context, "Name", owner!.name),
                      const SizedBox(height: 8),
                      _buildOwnerRow(context, "Email", owner!.email),
                      if (owner!.phoneNumber != null) ...[
                        const SizedBox(height: 8),
                        _buildOwnerRow(context, "Phone", owner!.phoneNumber!),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  height: 75,
                  width: 75,
                  child: FloatingActionButton(
                    backgroundColor: theme.colorScheme.secondary,
                    child: Icon(Icons.message,
                        color: theme.colorScheme.onSecondary),
                    onPressed: () {
                      if (user == null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Login Required"),
                              content: Text("Please log in to chat with the owner."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Ok"
                                    , style: TextStyle(color: Colors.greenAccent),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            receiverEmail: owner!.email,
                            receiverID: owner!.uid,
                            receiverName: owner!.name,
                            receiverProfilePicture:
                                owner!.profilePicture ?? "",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : "N/A",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 Helper Widgets
  Widget _infoChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(
        "$label: $value",
        style: theme.textTheme.bodyMedium,
      ),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
    );
  }

  Widget _specTile(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      title: Text(label, style: theme.textTheme.bodyMedium),
      trailing:
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}