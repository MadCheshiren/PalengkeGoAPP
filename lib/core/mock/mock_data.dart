class MockDataService {
  static const List<Map<String, dynamic>> featuredVendors = [
    {
      'id': 'v1',
      'name': 'Diosa Fruit Stand',
      'category': 'Fruits',
      'rating': 4.8,
      'isVerified': true,
      'distance': '1.2km',
      'imageUrl':
          'https://images.unsplash.com/photo-1488459716781-31db52582fe9?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'v2',
      'name': 'William Del Rosario Meat Shop',
      'category': 'Meat',
      'rating': 4.5,
      'isVerified': true,
      'distance': '0.8km',
      'imageUrl':
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'v3',
      "name": "Paul's Meat Shop",
      'category': 'Chicken',
      'rating': 4.9,
      'isVerified': false,
      'distance': '2.1km',
      'imageUrl':
          'https://images.unsplash.com/photo-1587593810167-a84920ea0781?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'v4',
      'name': 'Merly Diego Dried Fish Store',
      'category': 'Fish',
      'rating': 4.7,
      'isVerified': true,
      'distance': '1.5km',
      'imageUrl':
          'https://images.unsplash.com/photo-1599084993091-1cb5c0721cc6?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'v5',
      'name': 'Aling Nena Vegetables',
      'category': 'Vegetables',
      'rating': 4.9,
      'isVerified': true,
      'distance': '0.9km',
      'imageUrl':
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'v6',
      'name': 'Mang Pedro Seafood',
      'category': 'Fish',
      'rating': 4.7,
      'isVerified': false,
      'distance': '1.8km',
      'imageUrl':
          'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?q=80&w=400&auto=format&fit=crop',
    },
  ];

  static const List<Map<String, dynamic>> products = [
    // v1 - Diosa Fruit Stand (fruits)
    {
      'id': 'p1',
      'vendorId': 'v1',
      'name': 'Sweet Mangoes',
      'price': 150.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱150/kg',
      'description': 'Sweet and ripe',
      'imageUrl':
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=300&h=300&fit=crop',
    },
    {
      'id': 'p2',
      'vendorId': 'v1',
      'name': 'Bananas',
      'price': 60.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱60/kg',
      'description': 'Saba variety',
      'imageUrl':
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=300&h=300&fit=crop',
    },
    {
      'id': 'p3',
      'vendorId': 'v1',
      'name': 'Papaya',
      'price': 40.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱40/kg',
      'description': 'Fresh and sweet',
      'imageUrl':
          'https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=300&h=300&fit=crop',
    },
    {
      'id': 'p4',
      'vendorId': 'v1',
      'name': 'Pineapple',
      'price': 55.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱55/kg',
      'description': 'Queen variety',
      'imageUrl':
          'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=300&h=300&fit=crop',
    },
    // v2 - William Del Rosario Meat Shop
    {
      'id': 'p5',
      'vendorId': 'v2',
      'name': 'Pork Belly',
      'price': 280.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱280/kg',
      'description': 'Fresh cut',
      'imageUrl':
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=300&h=300&fit=crop',
    },
    {
      'id': 'p6',
      'vendorId': 'v2',
      'name': 'Chicken Breast',
      'price': 220.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱220/kg',
      'description': 'Boneless',
      'imageUrl':
          'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=300&h=300&fit=crop',
    },
    {
      'id': 'p7',
      'vendorId': 'v2',
      'name': 'Ground Beef',
      'price': 350.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱350/kg',
      'description': 'Lean cut',
      'imageUrl':
          'https://images.unsplash.com/photo-1602470520998-f4a52199a3d6?w=300&h=300&fit=crop',
    },
    // v3 - Paul's Meat Shop (chicken)
    {
      'id': 'p8',
      'vendorId': 'v3',
      'name': 'Whole Chicken',
      'price': 180.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱180/kg',
      'description': 'Native chicken',
      'imageUrl':
          'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=300&h=300&fit=crop',
    },
    {
      'id': 'p9',
      'vendorId': 'v3',
      'name': 'Chicken Wings',
      'price': 200.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱200/kg',
      'description': 'Party wings',
      'imageUrl':
          'https://images.unsplash.com/photo-1527477396000-e27163b4bbed?w=300&h=300&fit=crop',
    },
    // v4 - Merly Diego Dried Fish Store
    {
      'id': 'p10',
      'vendorId': 'v4',
      'name': 'Dried Squid',
      'price': 300.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱300/kg',
      'description': 'Sun-dried',
      'imageUrl':
          'https://images.unsplash.com/photo-1599084993091-1cb5c0721cc6?w=300&h=300&fit=crop',
    },
    {
      'id': 'p11',
      'vendorId': 'v4',
      'name': 'Dried Fish',
      'price': 250.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱250/kg',
      'description': 'Daing na bangus',
      'imageUrl':
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300&h=300&fit=crop',
    },
    // v5 - Aling Nena Vegetables
    {
      'id': 'p12',
      'vendorId': 'v5',
      'name': 'Tomatoes',
      'price': 40.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱40/kg',
      'description': 'Kamatis',
      'imageUrl':
          'https://images.unsplash.com/photo-1546470427-e26264e9b5a4?w=300&h=300&fit=crop',
    },
    {
      'id': 'p13',
      'vendorId': 'v5',
      'name': 'Onions',
      'price': 100.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱100/kg',
      'description': 'Sibuyas',
      'imageUrl':
          'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=300&h=300&fit=crop',
    },
    {
      'id': 'p14',
      'vendorId': 'v5',
      'name': 'Potatoes',
      'price': 80.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱80/kg',
      'description': 'Patatas',
      'imageUrl':
          'https://images.unsplash.com/photo-1518977676601-b28f0b0f0f0f?w=300&h=300&fit=crop',
    },
    // v6 - Mang Pedro Seafood
    {
      'id': 'p15',
      'vendorId': 'v6',
      'name': 'Tilapia',
      'price': 120.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱120/kg',
      'description': 'Fresh catch',
      'imageUrl':
          'https://images.unsplash.com/photo-1599084993091-1cb5c0721cc6?w=300&h=300&fit=crop',
    },
    {
      'id': 'p16',
      'vendorId': 'v6',
      'name': 'Bangus (Milkfish)',
      'price': 180.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱180/kg',
      'description': 'Boneless available',
      'imageUrl':
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300&h=300&fit=crop',
    },
    {
      'id': 'p17',
      'vendorId': 'v6',
      'name': 'Tiger Prawns',
      'price': 350.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱350/kg',
      'description': 'Large size',
      'imageUrl':
          'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=300&h=300&fit=crop',
    },
    {
      'id': 'p18',
      'vendorId': 'v6',
      'name': 'Squid',
      'price': 280.00,
      'unit': 'kg',
      'weight': '1kg',
      'pricePerKg': '₱280/kg',
      'description': 'Fresh daily',
      'imageUrl':
          'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?w=300&h=300&fit=crop',
    },
  ];

  static List<Map<String, dynamic>> getProductsForVendor(String vendorId) {
    return products.where((p) => p['vendorId'] == vendorId).toList();
  }
}
