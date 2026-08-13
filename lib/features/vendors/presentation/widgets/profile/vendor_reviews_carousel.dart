import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/core/navigation/app_router.dart';
import 'package:palengkego/features/vendors/domain/vendor_review.dart';

class MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class VendorReviewsCarousel extends StatefulWidget {
  final List<VendorReview> reviews;

  const VendorReviewsCarousel({super.key, required this.reviews});

  @override
  State<VendorReviewsCarousel> createState() => _VendorReviewsCarouselState();
}

class _VendorReviewsCarouselState extends State<VendorReviewsCarousel> {
  late ScrollController _scrollController;
  Timer? _tickerTimer;
  Timer? _resumeTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.reviews.isNotEmpty) {
        _startAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isUserInteracting || !_scrollController.hasClients) return;

      final position = _scrollController.position;
      final maxScroll = position.maxScrollExtent;
      final current = position.pixels;

      if (maxScroll <= 0) return;

      if (current >= maxScroll) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(current + 0.4);
      }
    });
  }

  void _pauseAutoScroll() {
    _resumeTimer?.cancel();
    _isUserInteracting = true;
  }

  void _scheduleResume() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reviews.isEmpty) return const SizedBox.shrink();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          if (notification.dragDetails != null) {
            _pauseAutoScroll();
          }
        } else if (notification is ScrollEndNotification) {
          _scheduleResume();
        }
        return false;
      },
      child: Listener(
        onPointerDown: (_) {
          _pauseAutoScroll();
        },
        onPointerUp: (_) {
          _scheduleResume();
        },
        onPointerCancel: (_) {
          _scheduleResume();
        },
        child: SizedBox(
          height: 88,
          child: ScrollConfiguration(
            behavior: MouseDragScrollBehavior(),
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.reviews.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final review = widget.reviews[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.vendorReviews,
                      arguments: VendorReviewsRouteArgs(
                        vendorId: review.vendorId,
                      ),
                    );
                  },
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              review.customerName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFACC15),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${review.rating}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '"${review.comment}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
