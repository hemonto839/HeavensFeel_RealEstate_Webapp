import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realestate/accessories/horizontal_property_list.dart';
import 'package:realestate/accessories/navigation_card.dart';
import 'package:realestate/models/property.dart';
import 'package:realestate/pages/account_setting.dart';
import 'package:realestate/pages/footer_page.dart';
import 'package:realestate/pages/forms/auction_add_to_list.dart';
import 'package:realestate/pages/forms/property_add_to_list.dart';
import 'package:realestate/pages/property_details/property_page_show.dart';
import 'package:realestate/pages/sign_in.dart';
import 'package:realestate/accessories/hover_drop_down_menu.dart';
import 'package:realestate/services/firebase_auction.dart';
import 'package:realestate/services/firebase_properties.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;

  const HomePage({super.key, required this.onToggleTheme, this.themeMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //  final FirebaseProperties _firebaseProperties = FirebaseProperties();
  final TextEditingController _searchController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  late VideoPlayerController _vidcontroller;
  final appbartxtstyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );
  late bool isPremium = false;
  late String userImageUrl = '';

  @override
  void initState() {
    super.initState();
    _vidcontroller = VideoPlayerController.asset(
      "assets/videos/hompagevideo2.webm",
    );
    _vidcontroller.setLooping(true);
    _vidcontroller.setVolume(0.0);
    _vidcontroller.initialize().then((_) {
      setState(() {});
      _vidcontroller.play();
    });
    loadData();
    AuctionService().checkAndCloseAuctions();
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          isPremium = doc.data()?['isPremium'] ?? false;
          userImageUrl = doc.data()?['profilePicture'] ?? '';
        });
      } else {
        setState(() {
          isPremium = false;
          userImageUrl = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _vidcontroller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        isPremium = doc.data()?['isPremium'] ?? false;
        userImageUrl = doc.data()?['profilePicture'] ?? '';
      });
    }
  }

  Future<void> _filterFunction() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a district name")),
      );
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('properties')
          .where('district', isEqualTo: query)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No properties found in $query")),
        );
        return;
      }

      final searchResults = snapshot.docs
          .map((doc) => PropertyModel.fromMap(doc.data()))
          .toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyPageShow(
            pageType: PropertyPageType.all,
            searchResults: searchResults,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, asyncSnapshot) {
        final user = asyncSnapshot.data;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final isDarkMode =
                (widget.themeMode == ThemeMode.dark ||
                (widget.themeMode == ThemeMode.system &&
                    MediaQuery.of(context).platformBrightness ==
                        Brightness.dark));
            return Scaffold(
              appBar: !isWide
                  ? AppBar(
                      title: const Text("HeavensFeel"),
                      actions: [
                        IconButton(
                          tooltip: "Theme",
                          onPressed: widget.onToggleTheme,
                          icon: Icon(
                            isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                          ),
                        ),
                        if (user != null)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AccountSetting(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              backgroundImage: (userImageUrl != '')
                                  ? NetworkImage(userImageUrl)
                                  : null,
                              child: (userImageUrl == '')
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          )
                        else
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SignIn(
                                    onToggleTheme: widget.onToggleTheme,
                                    themeMode:
                                        widget.themeMode ?? ThemeMode.system,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    )
                  : null,

              drawer: !isWide
                  ? Drawer(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          DrawerHeader(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                            ),
                            child: Text(
                              "Menu",
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 50,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ListTile(
                            title: const Text("Buy"),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyPageShow(
                                  pageType: PropertyPageType.sale,
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            title: const Text("Rent"),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyPageShow(
                                  pageType: PropertyPageType.rent,
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            title: const Text("Sell"),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyAddToList(),
                              ),
                            ),
                          ),
                          ListTile(
                            title: const Text("Auction"),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyPageShow(
                                  pageType: PropertyPageType.auction,
                                ),
                              ),
                            ),
                          ),
                          if (isPremium)
                            ListTile(
                              title: const Text("Host Auction"),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AuctionAddToList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : null,

              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: isWide
                          ? MediaQuery.of(context).size.height *
                                0.7 // large viewport hero
                          : MediaQuery.of(context).size.height *
                                0.35, // smaller height on mobile
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_vidcontroller.value.isInitialized)
                            FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _vidcontroller.value.size.width,
                                height: _vidcontroller.value.size.height,
                                child: VideoPlayer(_vidcontroller),
                              ),
                            )
                          else
                            Container(color: Colors.black),

                          if (isWide)
                            Align(
                              alignment: Alignment.topCenter,
                              child: SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          HoverMenuButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      PropertyPageShow(
                                                        pageType:
                                                            PropertyPageType
                                                                .sale,
                                                      ),
                                                ),
                                              );
                                            },
                                            label: "Buy",
                                            items: [
                                              "House",
                                              "Apartment",
                                              "Plot",
                                            ],
                                            buttonTextStyle: appbartxtstyle,

                                            onSelected: (selected) async {
                                              final String selectedType =
                                                  selected.toLowerCase();
                                              // Fetch properties filtered by selected type
                                              final snapshot =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('properties')
                                                      .where(
                                                        'propertyType',
                                                        isEqualTo: selectedType,
                                                      )
                                                      .where(
                                                        'listingType',
                                                        isEqualTo: 'sale',
                                                      ) // Make sure Firestore has a `type` field
                                                      .get();

                                              final results = snapshot.docs
                                                  .map(
                                                    (doc) =>
                                                        PropertyModel.fromMap(
                                                          doc.data(),
                                                        ),
                                                  )
                                                  .toList();
                                                  Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        PropertyPageShow(
                                                      pageType:
                                                          PropertyPageType.sale,
                                                      searchResults: results,
                                                    ),
                                                  ),
                                                );
                                            },
                                          ),
                                          const SizedBox(width: 16),
                                            HoverMenuButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      PropertyPageShow(
                                                        pageType:
                                                            PropertyPageType
                                                                .rent,
                                                      ),
                                                ),
                                              );
                                            },
                                            label: "Rent",
                                            buttonTextStyle: appbartxtstyle,
                                            items: [
                                              "House",
                                              "Apartment",
                                              "Plot",
                                            ],
                                            onSelected: (selected) async {
                                              final String selectedType =
                                                  selected.toLowerCase();
                                              // Fetch properties filtered by selected type
                                              final snapshot =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('properties')
                                                      .where(
                                                        'propertyType',
                                                        isEqualTo: selectedType,
                                                      )
                                                      .where(
                                                        'listingType',
                                                        isEqualTo: 'rent',
                                                      ) // Make sure Firestore has a `type` field
                                                      .get();

                                              final results = snapshot.docs
                                                  .map(
                                                    (doc) =>
                                                        PropertyModel.fromMap(
                                                          doc.data(),
                                                        ),
                                                  )
                                                  .toList();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        PropertyPageShow(
                                                      pageType:
                                                          PropertyPageType.rent,
                                                      searchResults: results,
                                                    ),
                                                  ),
                                                );

                                            },
                                          ),
                                          if (user != null) ...[
                                          const SizedBox(width: 16),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      PropertyAddToList(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Sell",
                                              style: appbartxtstyle,
                                            ),
                                          ),
                                          ],
                                          const SizedBox(width: 16),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      PropertyPageShow(
                                                        pageType:
                                                            PropertyPageType
                                                                .auction,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Auction",
                                              style: appbartxtstyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // right nav(theme/profile/sign in etc.)
                                      Row(
                                        children: [
                                          if (isPremium == true) ...[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        AuctionAddToList(),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "Host Auction",
                                                style: appbartxtstyle,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                          ] else if (user == null) ...[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => SignIn(
                                                      onToggleTheme:
                                                          widget.onToggleTheme,
                                                      themeMode:
                                                          widget.themeMode ??
                                                          ThemeMode.system,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "Sign In",
                                                style: appbartxtstyle,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                          ],
                                          IconButton(
                                            tooltip: "theme",
                                            onPressed: widget.onToggleTheme,
                                            icon: Icon(
                                              isDarkMode
                                                  ? Icons.wb_sunny
                                                  : Icons.nights_stay,
                                            ),
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 16),
                                          if (user != null)
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        AccountSetting(),
                                                  ),
                                                );
                                              },
                                              child: CircleAvatar(
                                                radius: 25,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                backgroundImage:
                                                    (userImageUrl != '')
                                                    ? NetworkImage(userImageUrl)
                                                    : null,
                                                child: (userImageUrl == '')
                                                    ? const Icon(
                                                        Icons.person,
                                                        size: 30,
                                                        color: Colors.white,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (isWide) ...[
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Find a home in a neighborhood you love.",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),

                                  /// Search Bar Container
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    width: 600,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).shadowColor.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Dropdown
                                        // DropdownButtonHideUnderline(
                                        //   child: DropdownButton<String>(
                                        //     value: "For Sale",
                                        //     dropdownColor: Theme.of(
                                        //       context,
                                        //     ).colorScheme.surface,
                                        //     style: Theme.of(context)
                                        //         .textTheme
                                        //         .bodyMedium
                                        //         ?.copyWith(
                                        //           color: Theme.of(
                                        //             context,
                                        //           ).colorScheme.onSurface,
                                        //         ),
                                        //     items: ["For Sale", "For Rent"].map(
                                        //       (e) {
                                        //         return DropdownMenuItem(
                                        //           value: e,
                                        //           child: Text(
                                        //             e,
                                        //             style: Theme.of(context)
                                        //                 .textTheme
                                        //                 .bodyMedium
                                        //                 ?.copyWith(
                                        //                   color:
                                        //                       Theme.of(context)
                                        //                           .colorScheme
                                        //                           .onSurface,
                                        //                 ),
                                        //           ),
                                        //         );
                                        //       },
                                        //     ).toList(),
                                        //     onChanged: (value) {

                                        //     },
                                        //   ),
                                        // ),
                                        //const SizedBox(width: 16),

                                        // Search TextField
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText:
                                                  "Place, Neighborhood, School or Agent",
                                              hintStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant
                                                        .withOpacity(0.7),
                                                  ),
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Search Icon
                                        IconButton(
                                          icon: Icon(
                                            Icons.search,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            _filterFunction();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (!isWide) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Find a home in a neighborhood you love.",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // DropdownButtonHideUnderline(
                            //   child: DropdownButton<String>(
                            //     value: "For Sale",
                            //     items: ["For Sale", "For Rent"].map((e) {
                            //       return DropdownMenuItem(
                            //         value: e,
                            //         child: Text(
                            //           e,
                            //           style: theme.textTheme.bodyMedium,
                            //         ),
                            //       );
                            //     }).toList(),
                            //     onChanged: (_) {},
                            //   ),
                            // ),
                            // const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                            controller: _searchController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText:
                                                  "Place, Neighborhood, School or Agent",
                                              hintStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant
                                                        .withOpacity(0.7),
                                                  ),
                                            ),
                                            // style: Theme.of(context)
                                            //     .textTheme
                                            //     .bodyMedium
                                            //     ?.copyWith(
                                            //       color: Theme.of(
                                            //         context,
                                            //       ).colorScheme.onSurface,
                                            //     ),
                                          ),
                            ),
                            IconButton(
                                          icon: Icon(
                                            Icons.search,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            _filterFunction();
                                          },
                                        )
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    HorizontalPropertySection(
                      // sideGap: 0,
                      isWide: isWide,
                      title: "Featured Properties",
                      subtitle: "Handpicked best listings",
                      pageType: PropertyPageType.all,
                      onCardTap: (property) {
                        debugPrint("Tapped: ${property.title}");
                      },
                      sidePadding: (isWide ? 100 : 16),
                    ),
                    const SizedBox(height: 20),
                    HorizontalPropertySection(
                      // sideGap: 0,
                      isWide: isWide,
                      title: "Auctioned Properties",
                      subtitle: "Handpicked best listings",
                      pageType: PropertyPageType.auction,
                      onCardTap: (property) {
                        debugPrint("Tapped: ${property.title}");
                      },
                      sidePadding: (isWide ? 100 : 16),
                    ),
                    const SizedBox(height: 40),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide =
                            constraints.maxWidth >
                            800; // threshold for desktop view

                        final cards = [
                          NavigationCard(
                            title: "Buy",
                            subtitle: "Find Your Best Home Here",
                            buttonText: "Explore More",
                            imagePath: "assets/images/buy.webp",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyPageShow(
                                  pageType: PropertyPageType.sale,
                                ),
                              ),
                            ),
                          ),
                          NavigationCard(
                            title: "Rent",
                            subtitle: "Find Your Best Home Here",
                            buttonText: "Explore More",
                            imagePath: "assets/images/rent.webp",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyPageShow(
                                  pageType: PropertyPageType.rent,
                                ),
                              ),
                            ),
                          ),
                          NavigationCard(
                            title: "Sale",
                            subtitle: "List your property",
                            buttonText: "List Here",
                            imagePath: "assets/images/sell.webp",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyAddToList(),
                              ),
                            ),
                          ),

                          NavigationCard(
                            title: "Auction",
                            subtitle: "Find Your Best Home Here",
                            buttonText: "Explore More",
                            imagePath: "assets/images/buy.webp",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PropertyPageShow(
                                  pageType: PropertyPageType.auction,
                                ),
                              ),
                            ),
                          ),
                        ];

                        if (isWide) {
                          // Desktop: show in a row with spacing
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: cards.map((card) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: card,
                                ),
                              );
                            }).toList(),
                          );
                        } else {
                          // Mobile: show as a column
                          return Column(
                            children: cards.map((card) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: card,
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                    const AppFooter(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
