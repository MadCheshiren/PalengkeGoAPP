/// Domain model for a vendor's stall configuration.
class VendorStall {
  final String name;
  final String description;
  final String category;
  final String location;
  final String? bannerImage;
  final String? avatarImage;
  final bool isOpen;

  const VendorStall({
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    this.bannerImage,
    this.avatarImage,
    required this.isOpen,
  });

  VendorStall copyWith({
    String? name,
    String? description,
    String? category,
    String? location,
    String? bannerImage,
    String? avatarImage,
    bool? isOpen,
    bool clearBanner = false,
    bool clearAvatar = false,
  }) {
    return VendorStall(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      bannerImage: clearBanner ? null : (bannerImage ?? this.bannerImage),
      avatarImage: clearAvatar ? null : (avatarImage ?? this.avatarImage),
      isOpen: isOpen ?? this.isOpen,
    );
  }
}
