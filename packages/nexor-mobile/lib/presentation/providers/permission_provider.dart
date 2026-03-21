import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/permissions/permission_rule.dart';

// Permission Service Provider
final permissionServiceProvider = Provider<PermissionService>((ref) {
  final service = PermissionService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Permission Rules Stream Provider
final permissionRulesProvider = StreamProvider<List<PermissionRule>>((ref) {
  final service = ref.watch(permissionServiceProvider);
  return service.rulesStream;
});

// Permission Notifier
class PermissionNotifier extends StateNotifier<AsyncValue<void>> {
  final PermissionService _service;

  PermissionNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> addRule(PermissionRule rule) async {
    state = const AsyncValue.loading();
    try {
      await _service.addRule(rule);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> removeRule(PermissionRule rule) async {
    state = const AsyncValue.loading();
    try {
      await _service.removeRule(rule);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> clearAllRules() async {
    state = const AsyncValue.loading();
    try {
      await _service.clearAllRules();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearSessionRules() {
    _service.clearSessionRules();
  }
}

final permissionNotifierProvider =
    StateNotifierProvider<PermissionNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(permissionServiceProvider);
  return PermissionNotifier(service);
});
