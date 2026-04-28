import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum AppConnectionType {
  none,
  wifi,
  ethernet,
  mobile,
  vpn,
  bluetooth,
  satellite,
  other,
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Current active connection list
  Future<List<ConnectivityResult>> getActiveConnections() async {
    try {
      final results = await _connectivity.checkConnectivity();

      if (results.isEmpty) {
        return [ConnectivityResult.none];
      }

      return results;
    } catch (e) {
      print('❌ getActiveConnections error: $e');
      return [ConnectivityResult.none];
    }
  }

  /// Primary connection type for app logic
  Future<AppConnectionType> getPrimaryConnectionType() async {
    final results = await getActiveConnections();
    return _mapToPrimaryType(results);
  }

  /// Any network connected or not
  Future<bool> isConnected() async {
    final results = await getActiveConnections();
    return !_containsOnlyNone(results);
  }

  /// FileHive ke liye important:
  /// WiFi / Hotspot / Ethernet par hi local transfer possible hai
  Future<bool> canUseLocalNetwork() async {
    final results = await getActiveConnections();

    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  Future<bool> isWifiConnected() async {
    final results = await getActiveConnections();
    return results.contains(ConnectivityResult.wifi);
  }

  Future<bool> isEthernetConnected() async {
    final results = await getActiveConnections();
    return results.contains(ConnectivityResult.ethernet);
  }

  Future<bool> isMobileConnected() async {
    final results = await getActiveConnections();
    return results.contains(ConnectivityResult.mobile);
  }

  /// App-friendly stream
  Stream<AppConnectionType> get connectionStream async* {
    yield await getPrimaryConnectionType();

    yield* _connectivity.onConnectivityChanged.map(_mapToPrimaryType);
  }

  /// Raw connectivity stream
  Stream<List<ConnectivityResult>> get rawConnectionStream {
    return _connectivity.onConnectivityChanged;
  }

  /// Start listener
  void startListening({
    required void Function(AppConnectionType type) onChanged,
  }) {
    stopListening();

    _subscription = _connectivity.onConnectivityChanged.listen(
          (results) {
        final type = _mapToPrimaryType(results);
        onChanged(type);
      },
      onError: (e) {
        print('❌ Connectivity listener error: $e');
        onChanged(AppConnectionType.none);
      },
    );
  }

  /// Stop listener
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stopListening();
  }

  /// Human readable text
  String connectionTypeToText(AppConnectionType type) {
    switch (type) {
      case AppConnectionType.wifi:
        return 'Wi-Fi';
      case AppConnectionType.ethernet:
        return 'Ethernet';
      case AppConnectionType.mobile:
        return 'Mobile Data';
      case AppConnectionType.vpn:
        return 'VPN';
      case AppConnectionType.bluetooth:
        return 'Bluetooth';
      case AppConnectionType.satellite:
        return 'Satellite';
      case AppConnectionType.other:
        return 'Other Network';
      case AppConnectionType.none:
        return 'No Connection';
    }
  }

  /// FileHive priority:
  /// WiFi > Ethernet > Mobile > VPN > Bluetooth > Satellite > Other
  AppConnectionType _mapToPrimaryType(List<ConnectivityResult> results) {
    if (_containsOnlyNone(results)) {
      return AppConnectionType.none;
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return AppConnectionType.wifi;
    }

    if (results.contains(ConnectivityResult.ethernet)) {
      return AppConnectionType.ethernet;
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return AppConnectionType.mobile;
    }

    if (results.contains(ConnectivityResult.vpn)) {
      return AppConnectionType.vpn;
    }

    if (results.contains(ConnectivityResult.bluetooth)) {
      return AppConnectionType.bluetooth;
    }

    if (results.contains(ConnectivityResult.satellite)) {
      return AppConnectionType.satellite;
    }

    if (results.contains(ConnectivityResult.other)) {
      return AppConnectionType.other;
    }

    return AppConnectionType.none;
  }

  bool _containsOnlyNone(List<ConnectivityResult> results) {
    return results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none);
  }
}