import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filehive/services/network/connectivity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivityService', () {
    late ConnectivityService service;

    setUp(() {
      service = ConnectivityService();
    });

    tearDown(() {
      service.dispose();
    });

    // ── _mapToPrimaryType / connectionTypeToText ────────────────────────────

    test('connectionTypeToText returns correct label for each type', () {
      expect(service.connectionTypeToText(AppConnectionType.wifi),
          equals('Wi-Fi'));
      expect(service.connectionTypeToText(AppConnectionType.mobile),
          equals('Mobile Data'));
      expect(service.connectionTypeToText(AppConnectionType.ethernet),
          equals('Ethernet'));
      expect(service.connectionTypeToText(AppConnectionType.vpn),
          equals('VPN'));
      expect(service.connectionTypeToText(AppConnectionType.bluetooth),
          equals('Bluetooth'));
      expect(service.connectionTypeToText(AppConnectionType.satellite),
          equals('Satellite'));
      expect(service.connectionTypeToText(AppConnectionType.other),
          equals('Other Network'));
      expect(service.connectionTypeToText(AppConnectionType.none),
          equals('No Connection'));
    });

    // ── Listener helpers ───────────────────────────────────────────────────

    test('stopListening can be called when no listener is active', () {
      expect(() => service.stopListening(), returnsNormally);
    });

    test('dispose can be called multiple times without throwing', () {
      expect(() {
        service.dispose();
        service.dispose();
      }, returnsNormally);
    });

    test('startListening and stopListening do not throw', () {
      expect(() {
        service.startListening((_) {});
        service.stopListening();
      }, returnsNormally);
    });

    test('rawConnectionStream is a Stream', () {
      expect(service.rawConnectionStream, isA<Stream>());
    });

    // ── AppConnectionType enum coverage ───────────────────────────────────

    test('AppConnectionType has expected values', () {
      expect(AppConnectionType.values, containsAll([
        AppConnectionType.none,
        AppConnectionType.wifi,
        AppConnectionType.mobile,
        AppConnectionType.ethernet,
        AppConnectionType.vpn,
        AppConnectionType.bluetooth,
        AppConnectionType.satellite,
        AppConnectionType.other,
      ]));
    });

    // ── ConnectivityResult mapping (unit-tested via public API) ────────────

    test('connectionTypeToText covers all enum variants without throwing', () {
      for (final type in AppConnectionType.values) {
        expect(() => service.connectionTypeToText(type), returnsNormally);
        expect(service.connectionTypeToText(type), isNotEmpty);
      }
    });

    // ── getActiveConnections returns a list ────────────────────────────────
    //
    // In a test environment connectivity_plus returns [ConnectivityResult.none]
    // on platforms where the underlying plugin is not available, so we assert
    // the return type rather than a specific value.

    test('getActiveConnections returns a List<ConnectivityResult>', () async {
      final result = await service.getActiveConnections();
      expect(result, isA<List<ConnectivityResult>>());
    });

    test('getPrimaryConnectionType returns an AppConnectionType', () async {
      final type = await service.getPrimaryConnectionType();
      expect(type, isA<AppConnectionType>());
    });

    test('isConnected returns a bool', () async {
      final connected = await service.isConnected();
      expect(connected, isA<bool>());
    });

    test('isWifiConnected returns a bool', () async {
      final result = await service.isWifiConnected();
      expect(result, isA<bool>());
    });

    test('isMobileConnected returns a bool', () async {
      final result = await service.isMobileConnected();
      expect(result, isA<bool>());
    });

    test('isEthernetConnected returns a bool', () async {
      final result = await service.isEthernetConnected();
      expect(result, isA<bool>());
    });
  });
}
