import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palengkego/core/utils/image_picker_helper.dart';

class StallPhotoEditor extends StatelessWidget {
  final String? bannerImage;
  final String? avatarImage;
  final ValueChanged<String?> onBannerChanged;
  final ValueChanged<String?> onAvatarChanged;

  const StallPhotoEditor({
    super.key,
    required this.bannerImage,
    required this.avatarImage,
    required this.onBannerChanged,
    required this.onAvatarChanged,
  });

  Future<void> _pickBanner(BuildContext context) async {
    final file = await ImagePickerHelper.pickImage(context);
    if (file != null) {
      onBannerChanged(file.path);
    }
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final file = await ImagePickerHelper.pickImage(context);
    if (file != null) {
      onAvatarChanged(file.path);
    }
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover photo / Background card
          GestureDetector(
            onTap: () => _pickBanner(context),
            child: Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD5E7DE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                image: bannerImage != null
                    ? DecorationImage(
                        image: _getImageProvider(bannerImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  if (bannerImage == null)
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: Color(0xFF0B372B),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Add Cover Photo',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0B372B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Profile Avatar bubble overlapping
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _pickAvatar(context),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        image: avatarImage != null
                            ? DecorationImage(
                                image: _getImageProvider(avatarImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: avatarImage == null
                          ? const Icon(
                              Icons.storefront_rounded,
                              size: 38,
                              color: Color(0xFF0B372B),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickAvatar(context),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B372B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
