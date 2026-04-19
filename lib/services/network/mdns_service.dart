import 'package:multicast_dns/multicast_dns.dart';

class MdnsService {
  final MDnsClient _client = MDnsClient();

  // 🔹 Start mDNS
  Future<void> start() async {
    await _client.start();
  }

  // 🔹 Stop mDNS
  Future<void> stop() async {
    _client.stop();
  }

  // 🔹 Scan devices (Service Discovery)
  Future<List<DiscoveredDevice>> scanDevices() async {
    List<DiscoveredDevice> devices = [];

    // yaha service type define karo (same hona chahiye sender & receiver me)
    const String serviceType = '_filehive._tcp.local';

    await for (PtrResourceRecord ptr
    in _client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer(serviceType))) {

      await for (SrvResourceRecord srv
      in _client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName))) {

        await for (IPAddressResourceRecord ip
        in _client.lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(srv.target))) {

          devices.add(
            DiscoveredDevice(
              name: ptr.domainName,
              ip: ip.address.address,
              port: srv.port,
            ),
          );
        }
      }
    }

    return devices;
  }
}

// 🔹 Model class
class DiscoveredDevice {
  final String name;
  final String ip;
  final int port;

  DiscoveredDevice({
    required this.name,
    required this.ip,
    required this.port,
  });
}