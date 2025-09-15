import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realestate/models/property.dart';
import 'package:realestate/services/firebase_auction.dart';
import 'package:realestate/services/firebase_user.dart';

class BiddingPage extends StatefulWidget {
  final PropertyModel property;

  const BiddingPage({super.key, required this.property});

  @override
  State<BiddingPage> createState() => _BiddingPageState();
}

class _BiddingPageState extends State<BiddingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  String auctionId = '';
  final TextEditingController _bidController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAuctionId();
  }

  Future<void> getAuctionId() async {
    final id =
        await AuctionService().getAuctionIdByPropertyId(widget.property.id);

    if (mounted) {
      setState(() {
        auctionId = id ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> placeBid() async {
    if (_bidController.text.isEmpty) return;

    final bidAmount = int.tryParse(_bidController.text);
    if (bidAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid number")),
      );
      return;
    }

    try {
      await AuctionService().placeBid(
        auctionId: auctionId,
        userId: userId,
        bidAmount: bidAmount,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bid placed successfully!")),
      );

      _bidController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place bid: $e")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getBidDetails(String auctionId) async {
    return await AuctionService().getBidHistory(auctionId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auctionId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Bidding Page"),
        ),
        body: const Center(
          child: Text("No auction found for this property."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Auction Details"),
        // backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Property Info Card ----------
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.property.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 18, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.property.city}, ${widget.property.country}",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------- Live Auction Card ----------
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('auctions').doc(auctionId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docSnapshot = snapshot.data;

                    if (docSnapshot == null || !docSnapshot.exists) {
                      return const Text("Auction data not found.");
                    }

                    final auctionData = docSnapshot.data()! as Map<String, dynamic>;
                    final highestBid = auctionData['currentBid'] ?? 0;
                    final endTime = (auctionData['endAt'] != null)
                        ? DateTime.tryParse(auctionData['endAt'])
                        : null;
                    final isActive = auctionData['isActive'] ?? false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Highest Bid",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                          "\$${highestBid.toString()}",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (endTime != null)
                          Row(
                            children: [
                              Icon(Icons.timer,
                                  size: 18, color: theme.colorScheme.secondary),
                              const SizedBox(width: 4),
                              Text(
                                "Ends at: ${endTime.toLocal()}",
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Text(
                          "Status: ${isActive ? "Active" : "Ended"}",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.error,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------- Place Bid Section ----------
            Text("Place Your Bid",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bidController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Enter your bid",
                      labelStyle: TextStyle(color: theme.colorScheme.onSurface),
                      // focusedBorder: OutlineInputBorder(
                      //   // borderSide: BorderSide(color: theme.colorScheme.primary),
                      //   borderRadius: BorderRadius.circular(8),
                      // ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: placeBid,
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Bid"),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---------- Bid History ----------
            Text("Bid History",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getBidDetails(auctionId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error fetching bid history"));
                }

                final bidHistory = snapshot.data ?? [];
                if (bidHistory.isEmpty) {
                  return const Text("No bids placed yet.");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bidHistory.length,
                  itemBuilder: (context, index) {
                    final bid = bidHistory[index];
                    return FutureBuilder<dynamic>(
                      future: FirebaseUser().getUserById(bid['user']),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            title: Text("Loading..."),
                          );
                        }
                        if (userSnapshot.hasError || userSnapshot.data == null) {
                          return ListTile(
                            leading: Icon(Icons.person,
                                color: theme.disabledColor),
                            title: Text("\$${bid['bid']}"),
                            subtitle: Text(
                              "Bidder: Unknown",
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          );
                        }
                        final user = userSnapshot.data;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(Icons.person,
                                  color: Colors.white),
                            ),
                            title: Text(
                              "\$${bid['bid']}",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Bidder: ${user.name ?? 'Unknown'}",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}