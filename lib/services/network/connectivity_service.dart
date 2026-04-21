import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum AppConnectionType {
  none,
  wifi,
  mobile,
  ethernet,
  vpn,
  bluetooth,
  satellite,
  other,
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Current active connection types laata hai
  Future<List<ConnectivityResult>> getActiveConnections() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result;
    } catch (e) {
      print('getActiveConnections error: $e');
      return [ConnectivityResult.none];
    }
  }

  /// App-friendly single primary connection type
  Future<AppConnectionType> getPrimaryConnectionType() async {
    final results = await getActiveConnections();
    return _mapToPrimaryType(results);
  }

  /// Kya kisi bhi type ka network available hai?
  Future<bool> isConnected() async {
    final results = await getActiveConnections();
    return !_containsOnlyNone(results);
  }

  /// Sirf Wi-Fi available hai ya nahi
  Future<bool> isWifiConnected() async {
    final results = await getActiveConnections();
    return results.contains(ConnectivityResult.wifi);
  }

  /// Mobile data available hai ya nahi
  Future<bool> isMobileConnected() async {
    final results = await getActiveConnections();
    return results.contains(ConnectivityResult.mobile);
  }

  /// Ethernet available hai ya nahi
  Future<bool> isEthernetConnected() async {
    final results = await getActiveConnections();
    return results.contains(ConnectivityResult.ethernet);
  }

  /// Connectivity changes stream
  Stream<AppConnectionType> get connectionStream async* {
    yield await getPrimaryConnectionType();

    yield* _connectivity.onConnectivityChanged.map(_mapToPrimaryType);
  }

  /// Raw stream bhi useful hoti hai debugging ya advanced logic ke liye
  Stream<List<ConnectivityResult>> get rawConnectionStream {
    return _connectivity.onConnectivityChanged;
  }

  /// Listener start karne ke liye helper
  void startListening(void Function(AppConnectionType type) onChanged) {
    stopListening();

    _subscription = _connectivity.onConnectivityChanged.listen(
          (results) {
        final type = _mapToPrimaryType(results);
        onChanged(type);
      },
      onError: (e) {
        print('Connectivity listener error: $e');
        onChanged(AppConnectionType.none);
      },
    );
  }

  /// Listener stop
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Dispose call kar dena provider/controller ke dispose me
  void dispose() {
    stopListening();
  }

  /// Human-readable text
  String connectionTypeToText(AppConnectionType type) {
    switch (type) {
      case AppConnectionType.wifi:
        return 'Wi-Fi';
      case AppConnectionType.mobile:
        return 'Mobile Data';
      case AppConnectionType.ethernet:
        return 'Ethernet';
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

  AppConnectionType _mapToPrimaryType(List<ConnectivityResult> results) {
    if (_containsOnlyNone(results)) return AppConnectionType.none;

    if (results.contains(ConnectivityResult.wifi)) {
      return AppConnectionType.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return AppConnectionType.mobile;
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return AppConnectionType.ethernet;
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
        (results.length == 1 && results.first == ConnectivityResult.none);
  }
}
