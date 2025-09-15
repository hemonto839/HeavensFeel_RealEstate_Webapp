import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:realestate/models/auction.dart';

class AuctionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String auctionCollection = 'auctions';
  final String propertyCollection = 'properties';

  // CREATE AUCTION
  Future<void> createAuction({
    required String propertyId,
    required int startingBid,
    required Duration duration,
  }) async {
    final now = DateTime.now();
    final endAt = now.add(duration);

    await _db.collection(auctionCollection).add({
      'propertyId': propertyId,
      'currentBid': startingBid,
      'highestBidder': '',
      'bidHistory': [],
      'createdAt': now.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'isActive': true,
    });

    // Mark property as "auction active"
    // await _db.collection(propertyCollection).doc(propertyId).update({
    //   'status': 'active',
    // });
  }

  // CHECK AND CLOSE AUCTIONS
  Future<void> checkAndCloseAuctions() async {
    final now = DateTime.now();
    final snapshot = await _db
        .collection(auctionCollection)
        .where('isActive', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final endAt = DateTime.parse(data['endAt']);

      if (now.isAfter(endAt)) {
        // Close the auction
        await _db.collection(auctionCollection).doc(doc.id).update({
          'isActive': false,
        });

        // Update property status
        await _db.collection(propertyCollection).doc(data['propertyId']).update({
          'status': 'inactive',
        });
      }
    }
  }

  // PLACE A BID
  Future<void> placeBid({
    required String auctionId,
    required String userId,
    required int bidAmount,
  }) async {
    final auctionDoc = _db.collection(auctionCollection).doc(auctionId);
    final snapshot = await auctionDoc.get();
    if (!snapshot.exists) return;

    final auction = snapshot.data()!;
    if (!auction['isActive']) return;

    final currentBid = auction['currentBid'];
    if (bidAmount <= currentBid) return;

    // Add bid to history
    List<dynamic> bidHistory = auction['bidHistory'];
    bidHistory.add({
      'user': userId,
      'bid': bidAmount,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await auctionDoc.update({
      'currentBid': bidAmount,
      'highestBidder': userId,
      'bidHistory': bidHistory,
    });
  }

   // GET AUCTION ID BY PROPERTY ID
  Future<String?> getAuctionIdByPropertyId(String propertyId) async {
    try {
      final query = await _db
          .collection(auctionCollection)
          .where('propertyId', isEqualTo: propertyId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id; // Auction ID
      } else {
        return null; // No auction found for this property
      }
    } catch (e) {
      print("Error fetching auction ID: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getBidHistory(String auctionId) async {
  try {
    final snapshot = await _db.collection(auctionCollection).doc(auctionId).get();

    if (!snapshot.exists) return [];

    final data = snapshot.data()!;
    final List<dynamic> bidHistory = data['bidHistory'] ?? [];

    // Sort descending by timestamp before returning
    bidHistory.sort((a, b) =>
        DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

    return bidHistory.cast<Map<String, dynamic>>();
  } catch (e) {
    print("Error fetching bid history: $e");
    return [];
  }
  }


}
