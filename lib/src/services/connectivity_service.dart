import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Observa o estado de conectividade do dispositivo para orientar a experiência
/// offline-first. É tolerante a falhas: qualquer erro da plataforma é tratado
/// como "assumir online" para não bloquear o login (a verificação real de
/// alcance do servidor acontece na tentativa de request).
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> initialize() async {
    try {
      final results = await _connectivity.checkConnectivity();
      isOnline.value = _isOnline(results);
      _subscription =
          _connectivity.onConnectivityChanged.listen((results) {
        isOnline.value = _isOnline(results);
      });
    } catch (e) {
      debugPrint('ConnectivityService: falha ao inicializar ($e). Assumindo online.');
      isOnline.value = true;
    }
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _subscription?.cancel();
    isOnline.dispose();
  }
}
