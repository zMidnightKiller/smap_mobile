import 'package:flutter/foundation.dart';

import '../data/repositories/dashboard_repository.dart';

/// Estado do Dashboard, alimentado pela base local (offline-first).
class DashboardProvider with ChangeNotifier {
  DashboardProvider({DashboardRepository? repository})
      : _repository = repository ?? DashboardRepository();

  final DashboardRepository _repository;

  DashboardResumo _resumo = DashboardResumo.empty;
  bool _isLoading = false;
  bool _loadedOnce = false;

  DashboardResumo get resumo => _resumo;
  bool get isLoading => _isLoading;
  bool get loadedOnce => _loadedOnce;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.bootstrap();
      _resumo = await _repository.resumo();
    } catch (e) {
      debugPrint('DashboardProvider.load erro: $e');
    } finally {
      _isLoading = false;
      _loadedOnce = true;
      notifyListeners();
    }
  }
}
