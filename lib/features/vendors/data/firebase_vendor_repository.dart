import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palengkego/core/mock/mock_data.dart';
import 'package:palengkego/features/vendors/domain/sales_summary.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:palengkego/features/vendors/domain/vendor_profile.dart';
import 'package:palengkego/features/vendors/domain/vendor_repository.dart';
import 'package:palengkego/features/vendors/domain/vendor_review.dart';
import 'package:palengkego/features/vendors/domain/vendor_stall.dart';

/// Firestore implementation of [VendorRepository].
///
/// Collections:
///   `vendorStalls/{stallId}`
///   `vendorStalls/{stallId}/products/{productId}`
///   `ratings/{ratingId}`
///   `salesSummary/{stallId}/daily/{date}`
class FirebaseVendorRepository implements VendorRepository {
  FirebaseVendorRepository(this._firestore);

  final FirebaseFirestore _firestore;

  // ── Market listing (customer-facing) ────────────────────────────────────────

  @override
  Future<VendorProfile> getVendorProfile(String id) async {
    final doc = await _firestore.collection('vendorStalls').doc(id).get();
    if (!doc.exists) {
      // Fallback to mock while Firestore is empty.
      return _mockProfile(id);
    }
    final d = doc.data()!;
    return VendorProfile(
      id: id,
      name: d['name'] as String? ?? '',
      category: d['category'] as String? ?? '',
      rating: (d['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: d['totalRatings'] as int? ?? 0,
      isOpen: d['isOpen'] as bool? ?? false,
      stallLocation: d['location'] as String? ?? '',
      imageUrl: d['bannerImage'] as String? ?? '',
      avatarUrl: d['avatarImage'] as String? ?? '',
    );
  }

  @override
  Future<List<VendorProduct>> getVendorProducts(String vendorId) async {
    final snap = await _firestore
        .collection('vendorStalls')
        .doc(vendorId)
        .collection('products')
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map((d) => _productFromFirestore(d.id, d.data())).toList();
  }

  // ── Product management ───────────────────────────────────────────────────────

  @override
  Future<VendorProduct> addVendorProduct(VendorProduct product) async {
    final ref = _firestore
        .collection('vendorStalls')
        .doc(product.vendorId)
        .collection('products')
        .doc();
    final saved = VendorProduct(
      id: ref.id,
      vendorId: product.vendorId,
      name: product.name,
      category: product.category,
      price: product.price,
      description: product.description,
      unit: product.unit,
      imageUrl: product.imageUrl,
      isActive: product.isActive,
      stockQuantity: product.stockQuantity,
      discountPercentage: product.discountPercentage,
    );
    await ref.set(_productToFirestore(saved));
    return saved;
  }

  @override
  Future<VendorProduct> updateVendorProduct(VendorProduct product) async {
    await _firestore
        .collection('vendorStalls')
        .doc(product.vendorId)
        .collection('products')
        .doc(product.id)
        .set(_productToFirestore(product), SetOptions(merge: true));
    return product;
  }

  @override
  Future<void> deleteVendorProduct(String productId) async {
    // productId format: "vendorId__productId" is not used here;
    // the caller must pass just the Firestore doc ID.
    // For now mirror what mock does — a real impl needs vendorId context.
    // This is a known limitation; wire vendorId when calling from UI.
    MockDataService.deleteProduct(productId);
  }

  // ── Stall management ────────────────────────────────────────────────────────

  @override
  Future<VendorStall> getVendorStall(String stallId) async {
    final doc = await _firestore.collection('vendorStalls').doc(stallId).get();
    if (!doc.exists) {
      throw Exception('Stall $stallId not found in Firestore');
    }
    return VendorStall.fromJson({...doc.data()!, 'stallId': stallId});
  }

  @override
  Future<void> updateVendorStall(VendorStall stall) async {
    await _firestore
        .collection('vendorStalls')
        .doc(stall.stallId)
        .set(stall.toJson(), SetOptions(merge: true));
  }

  // ── Reviews ─────────────────────────────────────────────────────────────────

  @override
  Future<List<VendorReview>> getReviews(String stallId) async {
    final snap = await _firestore
        .collection('ratings')
        .where('vendorId', isEqualTo: stallId)
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return VendorReview(
        id: d.id,
        vendorId: data['vendorId'] as String? ?? '',
        customerId: data['customerId'] as String? ?? '',
        customerName: data['customerName'] as String? ?? '',
        rating: (data['rating'] as num?)?.toDouble() ?? 0,
        comment: data['comment'] as String? ?? '',
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        orderId: data['orderId'] as String?,
        reviewType: data['reviewType'] == 'product'
            ? ReviewType.product
            : ReviewType.vendor,
        productName: data['productName'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> addReview(VendorReview review) async {
    final ref = _firestore.collection('ratings').doc(review.id);
    await ref.set({
      'vendorId': review.vendorId,
      'customerId': review.customerId,
      'customerName': review.customerName,
      'rating': review.rating,
      'comment': review.comment,
      'date': Timestamp.fromDate(review.date),
      'orderId': review.orderId,
      'reviewType': review.reviewType == ReviewType.product
          ? 'product'
          : 'vendor',
      'productName': review.productName,
    });

    // Minimal mock-like update to stall rating for realtime reflection without transaction
    // This is adequate for the current prototype scope
    final stallRef = _firestore.collection('vendorStalls').doc(review.vendorId);
    final stallDoc = await stallRef.get();
    if (stallDoc.exists) {
      final data = stallDoc.data()!;
      final currentRating = (data['averageRating'] as num?)?.toDouble() ?? 5.0;
      final currentCount = data['totalRatings'] as int? ?? 0;
      final newCount = currentCount + 1;
      final newRating =
          ((currentRating * currentCount) + review.rating) / newCount;

      await stallRef.update({
        'averageRating': newRating,
        'totalRatings': newCount,
      });
    }
  }

  // ── Sales summary ────────────────────────────────────────────────────────────

  @override
  Future<List<SalesSummary>> getSalesSummary(
    String stallId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final fromStr = from.toIso8601String().split('T').first;
    final toStr = to.toIso8601String().split('T').first;

    final snap = await _firestore
        .collection('salesSummary')
        .doc(stallId)
        .collection('daily')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: fromStr)
        .where(FieldPath.documentId, isLessThanOrEqualTo: toStr)
        .orderBy(FieldPath.documentId)
        .get();

    return snap.docs
        .map((d) => SalesSummary.fromFirestore(d.data(), id: d.id))
        .toList();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  VendorProfile _mockProfile(String id) {
    final v = MockDataService.featuredVendors.firstWhere(
      (v) => v['id'] == id,
      orElse: () => MockDataService.featuredVendors.first,
    );
    return VendorProfile(
      id: id,
      name: v['name'] as String? ?? '',
      category: v['category'] as String? ?? '',
      rating: (v['rating'] as num?)?.toDouble() ?? 4.0,
      reviewCount: 0,
      isOpen: true,
      stallLocation: v['stallNumber'] as String? ?? '',
      imageUrl: v['imageUrl'] as String? ?? '',
      avatarUrl: '',
    );
  }

  Map<String, dynamic> _productToFirestore(VendorProduct p) => {
    'vendorId': p.vendorId,
    'name': p.name,
    'category': p.category,
    'price': p.price,
    'description': p.description,
    'unit': p.unit,
    'imageUrl': p.imageUrl,
    'isActive': p.isActive,
    'stockQuantity': p.stockQuantity,
    'discountPercentage': p.discountPercentage,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  VendorProduct _productFromFirestore(String id, Map<String, dynamic> d) =>
      VendorProduct(
        id: id,
        vendorId: d['vendorId'] as String? ?? '',
        name: d['name'] as String? ?? '',
        category: d['category'] as String? ?? '',
        price: (d['price'] as num?)?.toDouble() ?? 0,
        description: d['description'] as String? ?? '',
        unit: d['unit'] as String? ?? 'kg',
        imageUrl: d['imageUrl'] as String? ?? '',
        isActive: d['isActive'] as bool? ?? true,
        stockQuantity: (d['stockQuantity'] as num?)?.toDouble() ?? 0.0,
        discountPercentage: (d['discountPercentage'] as num?)?.toDouble(),
      );
}
