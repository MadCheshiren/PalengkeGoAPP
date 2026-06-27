import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/market/application/market_provider.dart';
import 'package:palengkego/features/market/domain/market_product.dart';
import 'package:palengkego/features/vendors/application/vendor_provider.dart';
import 'package:palengkego/features/vendors/presentation/pages/vendor_profile_screen.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onTextChanged);
    _focus.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final text = _ctrl.text;
    if (text != _query) {
      setState(() => _query = text);
      _overlay?.markNeedsBuild();
    }
  }

  void _onFocusChanged() {
    if (_focus.hasFocus) {
      _showOverlay();
    } else {
      // Delay so a tap on an overlay result tile can complete before removal.
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focus.hasFocus) {
          _hideOverlay();
          setState(() {});
        }
      });
    }
  }

  void _showOverlay() {
    if (_overlay != null) return;
    _overlay = _buildOverlayEntry();
    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _clear() {
    _ctrl.clear();
    setState(() => _query = '');
    _overlay?.markNeedsBuild();
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (ctx) => _SearchDropdown(
        layerLink: _layerLink,
        query: _ctrl.text,
        onSelect: (product) {
          _ctrl.clear();
          setState(() => _query = '');
          _focus.unfocus();
          _hideOverlay();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VendorProfileScreen(vendorId: product.vendorId),
            ),
          );
        },
        onQueryChanged: () => _query,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTextChanged);
    _focus.removeListener(_onFocusChanged);
    _hideOverlay();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        decoration: BoxDecoration(
          color: _focus.hasFocus ? Colors.white : const Color(0xFFF6F8F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focus.hasFocus
                ? const Color(0xFF0B372B).withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _focus.hasFocus
                  ? const Color(0xFF0B372B).withValues(alpha: 0.08)
                  : const Color(0xFF000000).withValues(alpha: 0.04),
              offset: const Offset(0, 2),
              blurRadius: _focus.hasFocus ? 12 : 4,
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                _focus.hasFocus ? Icons.search_rounded : Icons.search_rounded,
                key: ValueKey(_focus.hasFocus),
                size: 18,
                color: _focus.hasFocus
                    ? const Color(0xFF0B372B)
                    : const Color(0xFF6D9773),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
                decoration: InputDecoration(
                  hintText: 'Search products, stalls...',
                  hintStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: _clear,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

// ── Overlay dropdown ─────────────────────────────────────────────────────────

class _SearchDropdown extends ConsumerWidget {
  final LayerLink layerLink;
  final String query;
  final ValueChanged<MarketProduct> onSelect;
  final String Function() onQueryChanged;

  const _SearchDropdown({
    required this.layerLink,
    required this.query,
    required this.onSelect,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchProductsProvider(query));
    final showEmpty = query.trim().isNotEmpty && results.isEmpty;

    // Only show if there's a query
    if (query.trim().isEmpty) return const SizedBox.shrink();

    return Positioned(
      width: MediaQuery.of(context).size.width,
      child: CompositedTransformFollower(
        link: layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 52), // sits just below the search bar
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 380),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B372B).withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: showEmpty
                    ? _emptyState(query)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount: results.length,
                        separatorBuilder: (_, index) => const Divider(
                          height: 1,
                          indent: 72,
                          endIndent: 16,
                          color: Color(0xFFF1F5F4),
                        ),
                        itemBuilder: (_, i) => _ProductResultTile(
                          product: results[i],
                          onTap: () => onSelect(results[i]),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String q) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 20, color: Color(0xFFCBD5E1)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No results for "$q"',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual result tile ────────────────────────────────────────────────────

class _ProductResultTile extends ConsumerWidget {
  final MarketProduct product;
  final VoidCallback onTap;

  const _ProductResultTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorProfileProvider(product.vendorId));

    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFF0B372B).withValues(alpha: 0.06),
      highlightColor: const Color(0xFF0B372B).withValues(alpha: 0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  width: 44,
                  height: 44,
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(
                    Icons.image_rounded,
                    size: 18,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + vendor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vendorAsync.when(
                      data: (v) => v.name,
                      loading: () => product.category,
                      error: (e, _) => product.category,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Price + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.pricePerKg,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B372B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.category,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
