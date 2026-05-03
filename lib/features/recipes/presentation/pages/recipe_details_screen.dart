import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  bool isFavorite = false;
  final Set<String> checkedIngredients = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar with Back Button and Favorite
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF0B372B),
                        ),
                      ),
                    ),
                    const Text(
                      'Recipe Details',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => isFavorite = !isFavorite),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isFavorite ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          size: 20,
                          color: isFavorite ? const Color(0xFFEF4444) : const Color(0xFF0B372B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Hero Image with Overlay
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.recipe['imageUrl'] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 280,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.image, size: 60, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB902),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'FILIPINO CLASSIC',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.recipe['name'] ?? 'Sinigang na Bangus',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.recipe['description'] ?? 'Tangy tamarind soup with milkfish and fresh vegetables',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatChip(
                    icon: Icons.timer_outlined,
                    label: 'TIME',
                    value: widget.recipe['time'] ?? '45 Mins',
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    icon: Icons.people_outline_rounded,
                    label: 'SERVING',
                    value: widget.recipe['serving'] ?? '4 Persons',
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    icon: Icons.local_fire_department_outlined,
                    label: 'ENERGY',
                    value: widget.recipe['calories'] ?? '320 kcal',
                  ),
                ],
              ),
            ),
          ),

          // Ingredients Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.recipe['ingredients']?.length ?? 7} Items',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B372B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildIngredientsList(),
                ],
              ),
            ),
          ),

          // Procedure Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Procedure',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProcedureSteps(),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF0B372B)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    final ingredients = widget.recipe['ingredients'] ?? _defaultIngredients;
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        final name = ingredient['name'] ?? ingredient.toString();
        final description = ingredient['description'] ?? '';
        final imageUrl = ingredient['imageUrl'];
        final isChecked = checkedIngredients.contains(name);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isChecked) {
                checkedIngredients.remove(name);
              } else {
                checkedIngredients.add(name);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isChecked ? const Color(0xFF0B372B) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isChecked ? const Color(0xFF0B372B) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked ? const Color(0xFF0B372B) : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isChecked ? const Color(0xFF0B372B) : const Color(0xFF1F2937),
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Ingredient image
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.image, size: 20, color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcedureSteps() {
    final steps = widget.recipe['steps'] ?? _defaultSteps;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final step = steps[index];
        final number = index + 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B372B),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (number < steps.length)
                  Container(
                    width: 2,
                    height: 60,
                    color: const Color(0xFFE2E8F0),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Step card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'] ?? 'Step $number',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['description'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Default data for demo
  final List<Map<String, dynamic>> _defaultIngredients = [
    {'name': 'Bangus (Milkfish)', 'description': '1 large, sliced into 3-4 pieces'},
    {'name': 'Kangkong (Water Spinach)', 'description': '2 bunches, trimmed and washed'},
    {'name': 'Tamarind', 'description': 'Fresh/powder: 1/2 cup mix'},
    {'name': 'Tomato', 'description': 'Onepiece, quartered'},
    {'name': 'Onion', 'description': '1 medium, sliced'},
    {'name': 'Radish', 'description': '1 small, sliced thinly'},
    {'name': 'Chili (Siling Hab\u00e0)', 'description': '2-3 pieces for heat'},
  ];

  final List<Map<String, dynamic>> _defaultSteps = [
    {
      'title': 'Boil the Broth Base',
      'description': 'In a large pot, bring 1 liter of water to a boil. Add the tamarind/powder mix, tomato, onion to extract juices. Simmer for 10 minutes until softened.',
    },
    {
      'title': 'Add Fish and Hard Veggies',
      'description': 'Gently drop in the Bangus slices and add the radish. Cover and simmer for 5-8 minutes. Be careful not to overcook the fish to maintain its flaky texture.',
    },
    {
      'title': 'Season and Finish',
      'description': 'Drop in the kangkong and green chilies. Season with fish sauce, patis or salt to taste. Turn off heat once cooked. Serve with steamed rice.',
    },
  ];
}
