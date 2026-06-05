import 'package:flutter/material.dart';
import 'package:palengkego/core/widgets/app_screen_header.dart';
import 'package:palengkego/features/vendors/application/vendor_stall_controller.dart';
import 'package:palengkego/features/vendors/domain/day_schedule.dart';
import 'package:palengkego/features/vendors/presentation/widgets/stall_photo_editor.dart';
import 'package:palengkego/features/vendors/presentation/widgets/stall_info_form.dart';
import 'package:palengkego/features/vendors/presentation/widgets/operating_hours_editor.dart';
import 'package:palengkego/features/vendors/presentation/widgets/stall_settings_save_button.dart';

class VendorStallSettingsScreen extends StatefulWidget {
  const VendorStallSettingsScreen({super.key});

  @override
  State<VendorStallSettingsScreen> createState() => _VendorStallSettingsScreenState();
}

class _VendorStallSettingsScreenState extends State<VendorStallSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  
  String _selectedCategory = 'Fish & Seafood';
  final List<String> _categories = [
    'Fish & Seafood',
    'Meat & Poultry',
    'Vegetables',
    'Fruits',
    'Rice & Grains',
    'Dried Goods & Spices',
  ];

  final List<DaySchedule> _schedules = [
    DaySchedule(name: 'Monday'),
    DaySchedule(name: 'Tuesday'),
    DaySchedule(name: 'Wednesday'),
    DaySchedule(name: 'Thursday'),
    DaySchedule(name: 'Friday'),
    DaySchedule(name: 'Saturday'),
    DaySchedule(name: 'Sunday'),
  ];

  String? _bannerImage;
  String? _avatarImage;

  @override
  void initState() {
    super.initState();
    final controller = VendorStallController.instance;
    _nameController = TextEditingController(text: controller.name);
    _descriptionController = TextEditingController(text: controller.description);
    _locationController = TextEditingController(text: controller.location);
    _selectedCategory = controller.category;
    _bannerImage = controller.bannerImage;
    _avatarImage = controller.avatarImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _applyMondayToAll() {
    final monday = _schedules[0];
    setState(() {
      for (int i = 1; i < _schedules.length; i++) {
        _schedules[i].isOpen = monday.isOpen;
        _schedules[i].openTime = monday.openTime;
        _schedules[i].closeTime = monday.closeTime;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0B372B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text(
          "Applied Monday's hours to all days",
          style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Save to global controller
      VendorStallController.instance.updateStall(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        bannerImage: _bannerImage ?? "",
        avatarImage: _avatarImage ?? "",
      );

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0B372B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text(
            'Stall settings and operating hours saved!',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppScreenHeader(title: 'Stall Settings'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StallPhotoEditor(
                        bannerImage: _bannerImage,
                        avatarImage: _avatarImage,
                        onBannerChanged: (url) => setState(() => _bannerImage = url),
                        onAvatarChanged: (url) => setState(() => _avatarImage = url),
                      ),
                      const SizedBox(height: 24),
                      StallInfoForm(
                        nameController: _nameController,
                        descriptionController: _descriptionController,
                        locationController: _locationController,
                        selectedCategory: _selectedCategory,
                        categories: _categories,
                        onCategoryChanged: (category) => setState(() => _selectedCategory = category),
                      ),
                      const SizedBox(height: 32),
                      OperatingHoursEditor(
                        schedules: _schedules,
                        onApplyMondayToAll: _applyMondayToAll,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 32),
                      StallSettingsSaveButton(onSave: _saveChanges),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
