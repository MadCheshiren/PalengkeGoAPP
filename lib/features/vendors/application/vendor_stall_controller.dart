import 'package:flutter/material.dart';

class VendorStallController extends ChangeNotifier {
  static final VendorStallController instance = VendorStallController._();
  VendorStallController._();

  String name = "Juan's Fresh Catch";
  String description = "We offer the freshest seafood directly from local ports. Quality and freshness guaranteed!";
  String category = 'Fish & Seafood';
  String location = "Stall 14, Wet Market Section";
  String? bannerImage;
  String? avatarImage;
  bool isOpen = true;

  void updateStall({
    String? name,
    String? description,
    String? category,
    String? bannerImage,
    String? avatarImage,
    bool? isOpen,
  }) {
    if (name != null) this.name = name;
    if (description != null) this.description = description;
    if (category != null) this.category = category;
    
    // We allow passing an empty string or null to reset image
    if (bannerImage != null) {
      this.bannerImage = bannerImage.isEmpty ? null : bannerImage;
    }
    if (avatarImage != null) {
      this.avatarImage = avatarImage.isEmpty ? null : avatarImage;
    }
    if (isOpen != null) this.isOpen = isOpen;
    notifyListeners();
  }
}
