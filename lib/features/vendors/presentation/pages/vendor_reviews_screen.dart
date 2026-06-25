import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/vendors/application/vendor_reviews_provider.dart';
import 'package:palengkego/features/vendors/domain/vendor_review.dart';

// ── Filter enum ───────────────────────────────────────────────────────────────

enum _ReviewFilter { all, five, four, three, two, one }

// ── Reusable Section ──────────────────────────────────────────────────────────

class VendorReviewsSection extends ConsumerStatefulWidget {
  final String? vendorId;

  const VendorReviewsSection({super.key, this.vendorId});

  @override
  ConsumerState<VendorReviewsSection> createState() =>
      _VendorReviewsSectionState();
}

class _VendorReviewsSectionState extends ConsumerState<VendorReviewsSection> {
  _ReviewFilter _filter = _ReviewFilter.all;

  List<VendorReview> _applyFilter(List<VendorReview> all) {
    switch (_filter) {
      case _ReviewFilter.five:
        return all.where((r) => r.rating.round() == 5).toList();
      case _ReviewFilter.four:
        return all.where((r) => r.rating.round() == 4).toList();
      case _ReviewFilter.three:
        return all.where((r) => r.rating.round() == 3).toList();
      case _ReviewFilter.two:
        return all.where((r) => r.rating.round() == 2).toList();
      case _ReviewFilter.one:
        return all.where((r) => r.rating.round() == 1).toList();
      case _ReviewFilter.all:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allReviews = widget.vendorId != null
        ? ref.watch(vendorReviewsFamilyProvider(widget.vendorId!))
        : ref.watch(vendorReviewsProvider);
    final filtered = _applyFilter(allReviews);

    if (allReviews.isEmpty) {
      return const _EmptyAllReviews();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _RatingSummaryCard(reviews: allReviews),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _FilterRow(
            selected: _filter,
            onChanged: (f) => setState(() => _filter = f),
            allReviews: allReviews,
          ),
        ),
        if (filtered.isEmpty)
          _EmptyFiltered(filter: _filter)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, idx) => const SizedBox(height: 10),
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: i == filtered.length - 1 ? 24 : 0,
              ),
              child: _ReviewCard(review: filtered[i]),
            ),
          ),
      ],
    );
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class VendorReviewsScreen extends ConsumerStatefulWidget {
  final String? vendorId;

  const VendorReviewsScreen({super.key, this.vendorId});

  @override
  ConsumerState<VendorReviewsScreen> createState() =>
      _VendorReviewsScreenState();
}

class _VendorReviewsScreenState extends ConsumerState<VendorReviewsScreen> {
  _ReviewFilter _filter = _ReviewFilter.all;

  List<VendorReview> _applyFilter(List<VendorReview> all) {
    switch (_filter) {
      case _ReviewFilter.five:
        return all.where((r) => r.rating.round() == 5).toList();
      case _ReviewFilter.four:
        return all.where((r) => r.rating.round() == 4).toList();
      case _ReviewFilter.three:
        return all.where((r) => r.rating.round() == 3).toList();
      case _ReviewFilter.two:
        return all.where((r) => r.rating.round() == 2).toList();
      case _ReviewFilter.one:
        return all.where((r) => r.rating.round() == 1).toList();
      case _ReviewFilter.all:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allReviews = widget.vendorId != null
        ? ref.watch(vendorReviewsFamilyProvider(widget.vendorId!))
        : ref.watch(vendorReviewsProvider);
    final filtered = _applyFilter(allReviews);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0B372B),
          ),
        ),
        title: Text(
          widget.vendorId != null ? 'Stall Reviews' : 'Customer Reviews',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B372B),
          ),
        ),
        centerTitle: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: allReviews.isEmpty
          ? const _EmptyAllReviews()
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _RatingSummaryCard(reviews: allReviews),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _FilterRow(
                      selected: _filter,
                      onChanged: (f) => setState(() => _filter = f),
                      allReviews: allReviews,
                    ),
                  ),
                ),
                filtered.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyFiltered(filter: _filter),
                      )
                    : SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (context, idx) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) => Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: i == filtered.length - 1 ? 24 : 0,
                          ),
                          child: _ReviewCard(review: filtered[i]),
                        ),
                      ),
              ],
            ),
    );
  }
}

// ── Rating summary card ───────────────────────────────────────────────────────

class _RatingSummaryCard extends StatelessWidget {
  final List<VendorReview> reviews;

  const _RatingSummaryCard({required this.reviews});

  double get _avgRating {
    if (reviews.isEmpty) return 0;
    return reviews.fold(0.0, (s, r) => s + r.rating) / reviews.length;
  }

  int _countForStar(int star) =>
      reviews.where((r) => r.rating.round() == star).length;

  @override
  Widget build(BuildContext context) {
    final avg = _avgRating;
    final total = reviews.length;
    final counts = [5, 4, 3, 2, 1].map(_countForStar).toList();
    final maxCount = counts.reduce(math.max).clamp(1, 999999);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: big number + stars + total
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B372B),
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              _StarRow(rating: avg, size: 16),
              const SizedBox(height: 6),
              Text(
                '$total ${total == 1 ? "review" : "reviews"}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Right: distribution bars
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = counts[i];
                final fraction = count / maxCount;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: Color(0xFFFACC15),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0B372B),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 18,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter row ────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final _ReviewFilter selected;
  final ValueChanged<_ReviewFilter> onChanged;
  final List<VendorReview> allReviews;

  const _FilterRow({
    required this.selected,
    required this.onChanged,
    required this.allReviews,
  });

  int _count(_ReviewFilter f) {
    switch (f) {
      case _ReviewFilter.five:
        return allReviews.where((r) => r.rating.round() == 5).length;
      case _ReviewFilter.four:
        return allReviews.where((r) => r.rating.round() == 4).length;
      case _ReviewFilter.three:
        return allReviews.where((r) => r.rating.round() == 3).length;
      case _ReviewFilter.two:
        return allReviews.where((r) => r.rating.round() == 2).length;
      case _ReviewFilter.one:
        return allReviews.where((r) => r.rating.round() == 1).length;
      case _ReviewFilter.all:
        return allReviews.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    // List of (filter, label) pairs as explicit objects to avoid record syntax.
    final filterDefs = <MapEntry<_ReviewFilter, String>>[
      MapEntry(_ReviewFilter.all, 'All'),
      MapEntry(_ReviewFilter.five, '5★'),
      MapEntry(_ReviewFilter.four, '4★'),
      MapEntry(_ReviewFilter.three, '3★'),
      MapEntry(_ReviewFilter.two, '2★'),
      MapEntry(_ReviewFilter.one, '1★'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterDefs.map((entry) {
          final filterVal = entry.key;
          final label = entry.value;
          final isSelected = selected == filterVal;
          final count = _count(filterVal);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(filterVal),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0B372B) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0B372B)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                    if (filterVal != _ReviewFilter.all) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final VendorReview review;

  const _ReviewCard({required this.review});

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF0B372B),
      Color(0xFF1D4ED8),
      Color(0xFF7C3AED),
      Color(0xFFB45309),
      Color(0xFF065F46),
      Color(0xFF9D174D),
      Color(0xFF1E40AF),
      Color(0xFF92400E),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  String _relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) {
      final y = (diff.inDays / 365).floor();
      return '$y ${y == 1 ? "year" : "years"} ago';
    }
    if (diff.inDays >= 30) {
      final m = (diff.inDays / 30).floor();
      return '$m ${m == 1 ? "month" : "months"} ago';
    }
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final isProductReview = review.reviewType == ReviewType.product;
    final initial =
        review.customerName.isNotEmpty ? review.customerName[0].toUpperCase() : '?';
    final avatarBg = _avatarColor(review.customerName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + name/date/stars
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: avatarBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            review.customerName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _relativeDate(review.date),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _StarRow(rating: review.rating, size: 13),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Review type tag
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: isProductReview && review.productName != null
                ? _ReviewTag(
                    icon: Icons.shopping_bag_outlined,
                    label: review.productName!,
                    bg: const Color(0xFFF0FDF4),
                    fg: const Color(0xFF166834),
                  )
                : const _ReviewTag(
                    icon: Icons.storefront_outlined,
                    label: 'Stall review',
                    bg: Color(0xFFF8FAFC),
                    fg: Color(0xFF64748B),
                  ),
          ),

          // Comment
          Text(
            review.comment,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF374151),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review type pill ──────────────────────────────────────────────────────────

class _ReviewTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  const _ReviewTag({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Star row ──────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating && (rating - i) >= 0.5;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: size,
          color: (filled || half)
              ? const Color(0xFFFACC15)
              : const Color(0xFFD1D5DB),
        );
      }),
    );
  }
}

// ── Empty states ──────────────────────────────────────────────────────────────

class _EmptyAllReviews extends StatelessWidget {
  const _EmptyAllReviews();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.rate_review_outlined,
                size: 36,
                color: Color(0xFF0B372B),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No reviews yet',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When customers leave feedback on\nyour stall or products, they appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFiltered extends StatelessWidget {
  final _ReviewFilter filter;

  const _EmptyFiltered({required this.filter});

  String get _label {
    switch (filter) {
      case _ReviewFilter.five:
        return '5-star';
      case _ReviewFilter.four:
        return '4-star';
      case _ReviewFilter.three:
        return '3-star';
      case _ReviewFilter.two:
        return '2-star';
      case _ReviewFilter.one:
        return '1-star';
      case _ReviewFilter.all:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.filter_list_off_rounded,
              size: 40,
              color: Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 16),
            Text(
              'No $_label reviews',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
