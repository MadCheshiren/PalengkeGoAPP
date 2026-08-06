import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/infrastructure/firebase_service.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/home/data/firebase_announcement_repository.dart';
import 'package:palengkego/features/home/data/mock_announcement_repository.dart';
import 'package:palengkego/features/home/domain/announcement_repository.dart';
import 'package:palengkego/features/home/domain/system_announcement.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  final firebaseEnabled = ref.watch(firebaseEnabledProvider);
  if (firebaseEnabled) {
    final firestore = ref.watch(firestoreProvider);
    return FirebaseAnnouncementRepository(firestore);
  }
  return MockAnnouncementRepository();
});

final activeAnnouncementsProvider = FutureProvider<List<SystemAnnouncement>>((
  ref,
) async {
  final repository = ref.watch(announcementRepositoryProvider);
  final authFuture = ref.watch(authStateProvider.future);
  final user = await authFuture;
  final role = user?.isVendor == true ? 'stall holder' : 'customer';
  return repository.getActiveAnnouncements(role);
});
