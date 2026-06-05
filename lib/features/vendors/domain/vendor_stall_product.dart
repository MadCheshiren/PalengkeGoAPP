import 'package:flutter/material.dart';

class VendorStallProduct {
  VendorStallProduct({
    required this.name,
    required this.price,
    required this.imageColor,
    required this.isActive,
  });

  final String name;
  final String price;
  final Color imageColor;
  bool isActive;
}
