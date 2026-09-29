import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_data.dart';

final AutoDisposeFutureProvider<DashboardData> dashboardDataProvider =
    FutureProvider.autoDispose<DashboardData>((Ref ref) async {
  final DashboardRepository repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDashboardData();
});
